import os
from fastapi import FastAPI, Depends, HTTPException, status, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from datetime import datetime
import json
from fastapi.staticfiles import StaticFiles

from database import engine, Base, SessionLocal, init_db
from database import Facture, AuditLog, Fournisseur, RegleConformite, Utilisateur
from auth import authenticate_user, create_access_token, get_current_user, require_role
from ocr_engine import extract_invoice_data
from compliance import check_compliance
from fraud_detector import detect_fraud

# Création des tables
Base.metadata.create_all(bind=engine)

app = FastAPI(title="Secure Invoice AI API", version="1.0.0")

# CORS middleware pour le frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all for dev
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialisation de la BDD au démarrage
@app.on_event("startup")
def on_startup():
    init_db()
    # Ensure uploads directory exists
    os.makedirs("uploads", exist_ok=True)

# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# --- Auth Endpoints ---

@app.post("/api/auth/login")
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = authenticate_user(db, form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Email ou mot de passe incorrect",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token = create_access_token(data={"sub": user.email})
    return {"access_token": access_token, "token_type": "bearer", "user": {
        "id": user.id, "nom": user.nom, "email": user.email, "role": user.role
    }}

@app.get("/api/auth/me")
def read_users_me(current_user: Utilisateur = Depends(get_current_user)):
    return {
        "id": current_user.id, "nom": current_user.nom, 
        "email": current_user.email, "role": current_user.role
    }

# --- Factures Endpoints ---

@app.get("/api/factures")
def get_factures(current_user: Utilisateur = Depends(get_current_user), db: Session = Depends(get_db)):
    if current_user.role == "client":
        # Le client ne voit que ses factures
        return db.query(Facture).filter(Facture.cree_par_id == current_user.id).all()
    # Les comptables et admins voient tout
    return db.query(Facture).all()

@app.get("/api/factures/{facture_id}")
def get_facture(facture_id: int, current_user: Utilisateur = Depends(get_current_user), db: Session = Depends(get_db)):
    facture = db.query(Facture).filter(Facture.id == facture_id).first()
    if not facture:
        raise HTTPException(status_code=404, detail="Facture non trouvée")
    if current_user.role == "client" and facture.cree_par_id != current_user.id:
        raise HTTPException(status_code=403, detail="Accès refusé")
    return facture

@app.post("/api/factures")
def create_facture(
    facture_data: dict, 
    current_user: Utilisateur = Depends(get_current_user), 
    db: Session = Depends(get_db)
):
    # Récupérer les règles de conformité et fournisseurs
    rules = [{"code": r.code, "active": r.active} for r in db.query(RegleConformite).all()]
    fournisseurs = db.query(Fournisseur).all()
    factures_existantes = db.query(Facture).all()

    # Analyse
    conformite_res = check_compliance(facture_data, rules)
    fraude_res = detect_fraud(facture_data, fournisseurs, factures_existantes)

    # Création facture
    nouvelle_facture = Facture(
        fournisseur=facture_data.get("fournisseur"),
        numero=facture_data.get("numero"),
        date_facture=facture_data.get("date_facture"),
        devise=facture_data.get("devise", "EUR"),
        ht=facture_data.get("ht", 0.0),
        tva=facture_data.get("tva", 0.0),
        ttc=facture_data.get("ttc", 0.0),
        iban=facture_data.get("iban"),
        statut="controlee" if conformite_res["valide"] else "brouillon",
        cree_par_id=current_user.id,
        assignee_a="À assigner",
        conformite_valide=conformite_res["valide"],
        conformite_details=json.dumps(conformite_res["details"]),
        fraude_score=fraude_res["score"],
        fraude_justification=fraude_res["justification"],
        fraude_alertes=json.dumps(fraude_res["alertes"])
    )
    db.add(nouvelle_facture)
    db.commit()
    db.refresh(nouvelle_facture)

    # Log d'audit
    log_action = AuditLog(
        acteur=current_user.nom,
        action="CREATION_FACTURE",
        cible=f"Facture #{nouvelle_facture.id}",
        details=f"Création facture {nouvelle_facture.numero} - {nouvelle_facture.fournisseur}",
        ip_address="127.0.0.1"
    )
    log_analyse = AuditLog(
        acteur="Système AI",
        action="ANALYSE_FACTURE",
        cible=f"Facture #{nouvelle_facture.id}",
        details=f"Conformité: {conformite_res['valide']}, Risque Fraude: {fraude_res['score']}%",
        ip_address="127.0.0.1"
    )
    db.add(log_action)
    db.add(log_analyse)
    db.commit()

    return nouvelle_facture

@app.put("/api/factures/{facture_id}/statut")
def update_facture_statut(
    facture_id: int, 
    statut_data: dict, 
    current_user: Utilisateur = Depends(get_current_user), 
    db: Session = Depends(get_db)
):
    if current_user.role not in ["comptable", "admin"]:
        raise HTTPException(status_code=403, detail="Non autorisé à modifier le statut")

    facture = db.query(Facture).filter(Facture.id == facture_id).first()
    if not facture:
        raise HTTPException(status_code=404, detail="Facture non trouvée")
    
    nouveau_statut = statut_data.get("statut")
    ancien_statut = facture.statut
    facture.statut = nouveau_statut
    db.commit()

    log = AuditLog(
        acteur=current_user.nom,
        action="MODIFICATION_STATUT",
        cible=f"Facture #{facture.id}",
        details=f"Statut modifié: {ancien_statut} -> {nouveau_statut}",
        ip_address="127.0.0.1"
    )
    db.add(log)
    db.commit()

    return {"message": "Statut mis à jour"}

@app.post("/api/upload")
async def upload_invoice(
    file: UploadFile = File(...),
    current_user: Utilisateur = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    file_path = f"uploads/{file.filename}"
    with open(file_path, "wb") as f:
        f.write(await file.read())

    # OCR Extraction
    extracted_data = extract_invoice_data(file_path)

    log = AuditLog(
        acteur=current_user.nom,
        action="UPLOAD_DOCUMENT",
        cible=file.filename,
        details="Document uploadé et extraction OCR effectuée",
        ip_address="127.0.0.1"
    )
    db.add(log)
    db.commit()

    return {
        "filename": file.filename,
        "extracted_data": extracted_data,
        "message": "OCR effectué avec succès"
    }

# --- Administration Endpoints ---

@app.get("/api/audit")
def get_audit_logs(current_user: Utilisateur = Depends(get_current_user), db: Session = Depends(get_db)):
    if current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Accès réservé aux administrateurs")
    return db.query(AuditLog).order_by(AuditLog.date.desc()).all()

@app.get("/api/regles")
def get_regles(db: Session = Depends(get_db)):
    return db.query(RegleConformite).all()

@app.put("/api/regles/{regle_id}")
def toggle_regle(
    regle_id: int, 
    data: dict, 
    current_user: Utilisateur = Depends(get_current_user), 
    db: Session = Depends(get_db)
):
    if current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Accès réservé aux administrateurs")
    
    regle = db.query(RegleConformite).filter(RegleConformite.id == regle_id).first()
    if not regle:
        raise HTTPException(status_code=404, detail="Règle non trouvée")
    
    active = data.get("active", False)
    regle.active = active
    
    log = AuditLog(
        acteur=current_user.nom,
        action="MODIFICATION_REGLE",
        cible=regle.code,
        details=f"Règle activée: {active}",
        ip_address="127.0.0.1"
    )
    db.add(log)
    db.commit()
    
    return {"message": "Règle mise à jour"}

@app.get("/api/fournisseurs")
def get_fournisseurs(db: Session = Depends(get_db)):
    return db.query(Fournisseur).all()

# Service du frontend si compilé
frontend_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../frontend/dist"))
if os.path.exists(frontend_path):
    app.mount("/", StaticFiles(directory=frontend_path, html=True), name="frontend")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
