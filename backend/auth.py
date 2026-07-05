"""
=============================================================================
Secure Invoice AI — Module Authentification (auth.py)
=============================================================================
Gère la création et vérification des tokens JWT, le hachage des mots de
passe avec bcrypt, et les dépendances FastAPI pour le contrôle d'accès RBAC.
=============================================================================
"""

from datetime import datetime, timedelta
from typing import Optional, List

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import JWTError, jwt
from passlib.context import CryptContext
from sqlalchemy.orm import Session

from database import Utilisateur, get_db

# ─── Configuration JWT ────────────────────────────────────────────────────
# Clé secrète pour signer les tokens (à externaliser en production)
SECRET_KEY = "secure-invoice-ai-secret-key-2026-change-me-in-production"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60  # Durée de validité : 1 heure

# Utilise pbkdf2_sha256 via passlib pour un hachage sécurisé
pwd_context = CryptContext(schemes=["pbkdf2_sha256"], deprecated="auto")

# ─── Schéma de sécurité Bearer ───────────────────────────────────────────
security = HTTPBearer()


# ─── Fonctions utilitaires ────────────────────────────────────────────────

def hash_password(password: str) -> str:
    """Hache un mot de passe en clair avec bcrypt."""
    return pwd_context.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Vérifie qu'un mot de passe correspond à son hash bcrypt."""
    return pwd_context.verify(plain_password, hashed_password)


def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """
    Crée un token JWT signé avec HS256.
    
    Args:
        data: Données à encoder dans le token (sub, role, nom, etc.)
        expires_delta: Durée de validité personnalisée (défaut: 60 min)
    
    Returns:
        Token JWT encodé sous forme de chaîne
    """
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


def decode_token(token: str) -> dict:
    """
    Décode et valide un token JWT.
    
    Raises:
        HTTPException 401 si le token est invalide ou expiré
    """
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token invalide ou expiré.",
            headers={"WWW-Authenticate": "Bearer"},
        )


def authenticate_user(db: Session, email: str, password: str) -> Optional[Utilisateur]:
    """
    Authentifie un utilisateur par email et mot de passe.
    
    Returns:
        L'objet Utilisateur si les identifiants sont corrects, None sinon
    """
    user = db.query(Utilisateur).filter(Utilisateur.email == email).first()
    if not user:
        return None
    if not verify_password(password, user.mot_de_passe_hash):
        return None
    if not user.actif:
        return None
    return user


# ─── Dépendances FastAPI ──────────────────────────────────────────────────

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
) -> Utilisateur:
    """
    Dépendance FastAPI qui extrait l'utilisateur courant du token Bearer.
    
    Vérifie le token JWT, extrait l'email (claim 'sub'), et charge
    l'utilisateur depuis la base de données.
    
    Raises:
        HTTPException 401 si le token est absent, invalide, ou l'utilisateur introuvable
    """
    payload = decode_token(credentials.credentials)
    email: str = payload.get("sub")
    
    if email is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token invalide : identifiant utilisateur manquant.",
        )
    
    user = db.query(Utilisateur).filter(Utilisateur.email == email).first()
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Utilisateur non trouvé.",
        )
    
    if not user.actif:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Compte utilisateur désactivé.",
        )
    
    return user


def require_role(allowed_roles: List[str]):
    """
    Fabrique de dépendances pour le contrôle d'accès basé sur les rôles (RBAC).
    
    Usage:
        @app.get("/admin-only", dependencies=[Depends(require_role(["admin"]))])
        
    Ou dans les paramètres de l'endpoint :
        user: Utilisateur = Depends(require_role(["comptable", "admin"]))
    
    Args:
        allowed_roles: Liste des rôles autorisés à accéder à l'endpoint
    
    Returns:
        Dépendance FastAPI qui vérifie le rôle de l'utilisateur
    """
    async def role_checker(
        current_user: Utilisateur = Depends(get_current_user)
    ) -> Utilisateur:
        if current_user.role not in allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Accès refusé. Rôle requis : {', '.join(allowed_roles)}. "
                       f"Votre rôle : {current_user.role}.",
            )
        return current_user
    
    return role_checker
