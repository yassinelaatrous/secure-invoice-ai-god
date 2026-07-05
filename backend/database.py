"""
=============================================================================
Secure Invoice AI — Module Base de Données (database.py)
=============================================================================
Définit les modèles SQLAlchemy, le moteur de base de données SQLite,
et la fonction d'initialisation avec données de démonstration.
=============================================================================
"""

from sqlalchemy import (
    create_engine, Column, Integer, String, Float, Boolean, DateTime,
    Text, ForeignKey, Enum as SAEnum
)
from sqlalchemy.orm import declarative_base, sessionmaker, Session
from datetime import datetime, timedelta
import enum
import json
import os

# ─── Configuration du moteur SQLite ────────────────────────────────────────
# Le fichier de base de données est créé dans le répertoire backend
DB_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "secure_invoice.db")
DATABASE_URL = f"sqlite:///{DB_PATH}"

engine = create_engine(
    DATABASE_URL,
    connect_args={"check_same_thread": False},  # Nécessaire pour SQLite avec FastAPI
    echo=False
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


# ─── Énumérations ──────────────────────────────────────────────────────────

class StatutFacture(str, enum.Enum):
    """Les 7 statuts possibles d'une facture selon le cahier des charges."""
    brouillon = "brouillon"
    controlee = "controlee"
    validee = "validee"
    envoyee = "envoyee"
    payee = "payee"
    en_retard = "en_retard"
    annulee = "annulee"


class RoleUtilisateur(str, enum.Enum):
    """Rôles RBAC du système."""
    client = "client"
    comptable = "comptable"
    admin = "admin"


class DeviseType(str, enum.Enum):
    """Devises supportées."""
    TND = "TND"
    EUR = "EUR"
    USD = "USD"


class StatutConfiance(str, enum.Enum):
    """Niveau de confiance d'un fournisseur."""
    verifie = "verifie"
    en_attente = "en_attente"
    suspect = "suspect"


# ─── Modèles SQLAlchemy ───────────────────────────────────────────────────

class Utilisateur(Base):
    """Modèle utilisateur avec rôle RBAC (Client / Comptable / Admin)."""
    __tablename__ = "utilisateurs"

    id = Column(Integer, primary_key=True, autoincrement=True)
    nom = Column(String(100), nullable=False)
    email = Column(String(150), unique=True, nullable=False, index=True)
    mot_de_passe_hash = Column(String(255), nullable=False)
    role = Column(String(20), nullable=False, default=RoleUtilisateur.client.value)
    date_creation = Column(DateTime, default=datetime.utcnow)
    actif = Column(Boolean, default=True)


class Fournisseur(Base):
    """
    Fournisseur connu dans le système.
    Utilisé pour la vérification d'IBAN et la détection de fraude.
    """
    __tablename__ = "fournisseurs"

    id = Column(Integer, primary_key=True, autoincrement=True)
    nom = Column(String(50), nullable=False, unique=True)
    nom_complet = Column(String(200), nullable=False)
    iban_officiel = Column(String(34), nullable=True)
    montant_moyen_mensuel = Column(Float, default=0.0)
    devise = Column(String(5), default=DeviseType.TND.value)
    statut_confiance = Column(String(20), default=StatutConfiance.verifie.value)
    siret = Column(String(20), nullable=True)
    date_creation = Column(DateTime, default=datetime.utcnow)


class Facture(Base):
    """
    Modèle principal : la facture électronique.
    Contient les données financières, les résultats de conformité
    et le score de fraude.
    """
    __tablename__ = "factures"

    id = Column(Integer, primary_key=True, autoincrement=True)
    fournisseur = Column(String(200), nullable=False)
    numero = Column(String(50), nullable=False)
    date_facture = Column(String(20), nullable=True)  # Format YYYY-MM-DD ou JJ/MM/AAAA
    devise = Column(String(5), default=DeviseType.TND.value)
    ht = Column(Float, default=0.0)          # Montant hors taxes
    tva = Column(Float, default=0.0)         # Montant de la TVA
    ttc = Column(Float, default=0.0)         # Montant toutes taxes comprises
    iban = Column(String(34), nullable=True)
    statut = Column(String(20), default=StatutFacture.brouillon.value)
    date_creation = Column(DateTime, default=datetime.utcnow)
    cree_par_id = Column(Integer, ForeignKey("utilisateurs.id"), nullable=True)
    assignee_a = Column(String(100), nullable=True)

    # Résultats de l'analyse de conformité
    conformite_valide = Column(Boolean, default=False)
    conformite_details = Column(Text, default="[]")  # JSON sérialisé

    # Résultats de la détection de fraude
    fraude_score = Column(Integer, default=0)
    fraude_justification = Column(Text, default="")
    fraude_alertes = Column(Text, default="[]")  # JSON sérialisé


class RegleConformite(Base):
    """
    Règle de conformité paramétrable.
    Peut être activée/désactivée par un administrateur.
    """
    __tablename__ = "regles_conformite"

    id = Column(Integer, primary_key=True, autoincrement=True)
    code = Column(String(50), unique=True, nullable=False)
    nom = Column(String(100), nullable=False)
    description = Column(Text, nullable=True)
    active = Column(Boolean, default=True)


class AuditLog(Base):
    """
    Journal d'audit — trace toutes les actions importantes
    pour la conformité et la traçabilité.
    """
    __tablename__ = "audit_logs"

    id = Column(Integer, primary_key=True, autoincrement=True)
    date = Column(DateTime, default=datetime.utcnow)
    acteur = Column(String(150), nullable=False)
    action = Column(String(100), nullable=False)
    cible = Column(String(200), nullable=True)
    details = Column(Text, nullable=True)
    ip_address = Column(String(45), nullable=True)


# ─── Dépendance de session pour FastAPI ────────────────────────────────────

def get_db():
    """Générateur de session SQLAlchemy pour l'injection de dépendance FastAPI."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# ─── Initialisation et données de démonstration ───────────────────────────

def init_db():
    """
    Crée toutes les tables et insère les données de démonstration
    si la base est vide (première exécution).
    """
    from auth import hash_password  # Import tardif pour éviter la dépendance circulaire

    # Créer toutes les tables
    Base.metadata.create_all(bind=engine)

    db = SessionLocal()
    try:
        # Vérifier si des données existent déjà
        if db.query(Utilisateur).count() > 0:
            print("[INFO] Base de donnees deja initialisee.")
            return

        print("[INFO] Initialisation de la base de donnees...")

        # ── 1. Utilisateurs de démonstration ───────────────────────────
        utilisateurs = [
            Utilisateur(
                nom="Client Demo",
                email="client@demo.com",
                mot_de_passe_hash=hash_password("client123"),
                role=RoleUtilisateur.client.value
            ),
            Utilisateur(
                nom="Comptable Demo",
                email="comptable@demo.com",
                mot_de_passe_hash=hash_password("comptable123"),
                role=RoleUtilisateur.comptable.value
            ),
            Utilisateur(
                nom="Admin Demo",
                email="admin@demo.com",
                mot_de_passe_hash=hash_password("admin123"),
                role=RoleUtilisateur.admin.value
            ),
        ]
        db.add_all(utilisateurs)
        db.flush()  # Pour obtenir les IDs

        # ── 2. Fournisseurs connus ─────────────────────────────────────
        fournisseurs = [
            Fournisseur(
                nom="STEG",
                nom_complet="Société Tunisienne de l'Électricité et du Gaz",
                iban_officiel="TN5910006035183598983943",
                montant_moyen_mensuel=1500.0,
                devise=DeviseType.TND.value,
                statut_confiance=StatutConfiance.verifie.value,
                siret="0011223344"
            ),
            Fournisseur(
                nom="Orange Business Services",
                nom_complet="Orange Business Services S.A.",
                iban_officiel="FR7630006000011234567890189",
                montant_moyen_mensuel=3200.0,
                devise=DeviseType.EUR.value,
                statut_confiance=StatutConfiance.verifie.value,
                siret="38012986400034"
            ),
            Fournisseur(
                nom="Tunisie Telecom",
                nom_complet="Tunisie Telecom S.A.",
                iban_officiel="TN5914006099012734956823",
                montant_moyen_mensuel=800.0,
                devise=DeviseType.TND.value,
                statut_confiance=StatutConfiance.verifie.value,
                siret="0099887766"
            ),
            Fournisseur(
                nom="Amazon Web Services",
                nom_complet="Amazon Web Services Inc.",
                iban_officiel="DE89370400440532013000",
                montant_moyen_mensuel=5000.0,
                devise=DeviseType.USD.value,
                statut_confiance=StatutConfiance.verifie.value,
                siret="HRB123456"
            ),
            Fournisseur(
                nom="SOPAT",
                nom_complet="Société de Production Agricole de Tebourba",
                iban_officiel="TN5910006035100078901234",
                montant_moyen_mensuel=2000.0,
                devise=DeviseType.TND.value,
                statut_confiance=StatutConfiance.en_attente.value,
                siret="0055667788"
            ),
        ]
        db.add_all(fournisseurs)
        db.flush()

        # ── 3. Règles de conformité ───────────────────────────────────
        regles = [
            RegleConformite(
                code="CHAMPS_OBLIGATOIRES",
                nom="Champs obligatoires",
                description="Vérifie que tous les champs requis sont renseignés : "
                            "fournisseur, numéro, date, montants HT/TVA/TTC.",
                active=True
            ),
            RegleConformite(
                code="COHERENCE_TVA",
                nom="Cohérence TVA",
                description="Vérifie que HT + TVA = TTC avec une tolérance de 0.05.",
                active=True
            ),
            RegleConformite(
                code="VALIDITE_DATE",
                nom="Validité de la date",
                description="Vérifie que la date de facturation n'est pas dans le futur.",
                active=True
            ),
            RegleConformite(
                code="IBAN_VALIDE",
                nom="IBAN valide",
                description="Vérifie que l'IBAN a une longueur valide (15 à 34 caractères).",
                active=True
            ),
        ]
        db.add_all(regles)
        db.flush()

        # ── 4. Factures de démonstration ──────────────────────────────
        # Facture 1 : Scénario OK — tout est correct
        facture_ok = Facture(
            fournisseur="STEG",
            numero="STEG-2026-0451",
            date_facture="2026-06-15",
            devise=DeviseType.TND.value,
            ht=1200.00,
            tva=228.00,
            ttc=1428.00,
            iban="TN5910006035183598983943",
            statut=StatutFacture.controlee.value,
            cree_par_id=utilisateurs[0].id,
            conformite_valide=True,
            conformite_details=json.dumps([]),
            fraude_score=5,
            fraude_justification="Aucune anomalie détectée.",
            fraude_alertes=json.dumps([])
        )

        # Facture 2 : Erreur de TVA — HT + TVA ≠ TTC
        facture_tva_erreur = Facture(
            fournisseur="Orange Business Services",
            numero="OBS-2026-1287",
            date_facture="2026-06-20",
            devise=DeviseType.EUR.value,
            ht=2500.00,
            tva=475.00,
            ttc=3100.00,  # Devrait être 2975.00 → erreur volontaire
            iban="FR7630006000011234567890189",
            statut=StatutFacture.brouillon.value,
            cree_par_id=utilisateurs[0].id,
            conformite_valide=False,
            conformite_details=json.dumps([
                "COHERENCE_TVA : HT (2500.0) + TVA (475.0) = 2975.0 ≠ TTC (3100.0)"
            ]),
            fraude_score=10,
            fraude_justification="Incohérence TVA détectée, mais pas de signe de fraude majeur.",
            fraude_alertes=json.dumps([])
        )

        # Facture 3 : IBAN suspect — ne correspond pas au fournisseur connu
        facture_iban_suspect = Facture(
            fournisseur="Tunisie Telecom",
            numero="TT-2026-0893",
            date_facture="2026-07-01",
            devise=DeviseType.TND.value,
            ht=650.00,
            tva=123.50,
            ttc=773.50,
            iban="TN9999999999999999999999",  # IBAN différent de l'officiel
            statut=StatutFacture.brouillon.value,
            cree_par_id=utilisateurs[1].id,
            conformite_valide=True,
            conformite_details=json.dumps([]),
            fraude_score=72,
            fraude_justification="IBAN ne correspond pas à celui enregistré pour Tunisie Telecom.",
            fraude_alertes=json.dumps([
                "IBAN différent de l'IBAN officiel du fournisseur (+65 points)",
                "Alerte critique : risque de fraude par substitution d'IBAN"
            ])
        )

        # Facture 4 : Fournisseur inconnu — pas dans la base
        facture_inconnu = Facture(
            fournisseur="Société Fantôme SARL",
            numero="SF-2026-0001",
            date_facture="2026-06-28",
            devise=DeviseType.TND.value,
            ht=8500.00,
            tva=1615.00,
            ttc=10115.00,
            iban="TN0000000000000000000000",
            statut=StatutFacture.brouillon.value,
            cree_par_id=utilisateurs[0].id,
            conformite_valide=True,
            conformite_details=json.dumps([]),
            fraude_score=65,
            fraude_justification="Fournisseur inconnu dans la base de données.",
            fraude_alertes=json.dumps([
                "Fournisseur non référencé dans le système (+40 points)",
                "Montant inhabituellement élevé (+25 points)"
            ])
        )

        db.add_all([facture_ok, facture_tva_erreur, facture_iban_suspect, facture_inconnu])
        db.flush()

        # ── 5. Logs d'audit de démonstration ─────────────────────────
        logs = [
            AuditLog(
                date=datetime.utcnow() - timedelta(hours=3),
                acteur="admin@demo.com",
                action="INITIALISATION_SYSTEME",
                cible="Base de données",
                details="Création initiale de la base et des données de démonstration.",
                ip_address="127.0.0.1"
            ),
            AuditLog(
                date=datetime.utcnow() - timedelta(hours=2),
                acteur="client@demo.com",
                action="CREATION_FACTURE",
                cible="STEG-2026-0451",
                details="Facture créée avec succès. Conformité OK. Score fraude: 5.",
                ip_address="192.168.1.10"
            ),
            AuditLog(
                date=datetime.utcnow() - timedelta(hours=1),
                acteur="comptable@demo.com",
                action="ANALYSE_FRAUDE",
                cible="TT-2026-0893",
                details="Alerte fraude : IBAN suspect détecté (score 72/100).",
                ip_address="192.168.1.25"
            ),
            AuditLog(
                date=datetime.utcnow() - timedelta(minutes=30),
                acteur="client@demo.com",
                action="CREATION_FACTURE",
                cible="SF-2026-0001",
                details="Facture créée. Fournisseur inconnu. Score fraude: 65.",
                ip_address="192.168.1.10"
            ),
        ]
        db.add_all(logs)

        db.commit()
        print("[SUCCESS] Base de donnees initialisee avec les donnees de demonstration.")
        print("   -> 3 utilisateurs, 5 fournisseurs, 4 regles, 4 factures, 4 logs d'audit")

    except Exception as e:
        db.rollback()
        print(f"[ERROR] Erreur lors de l'initialisation : {e}")
        raise
    finally:
        db.close()
