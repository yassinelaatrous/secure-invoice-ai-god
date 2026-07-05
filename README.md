# Secure Invoice AI — Module WP4 : Mobile & OCR Capture

Plateforme SaaS de facturation électronique sécurisée avec extraction OCR, moteur de conformité paramétrable et détection de fraude explicable.

**Responsable du module :** Yassine Latrous (WP4 — Dev Web et Mobile)  
**Cadre :** Stage d'été — CEO-IT Platform — Juin-Août 2026

---

## Architecture technique

| Couche | Technologie | Justification |
|--------|------------|---------------|
| Frontend | React + TypeScript (Vite) | Framework moderne, performant, recommandé par le cahier des charges |
| Backend API | FastAPI (Python) | Rapidité de développement, documentation Swagger auto-générée |
| Base de données | SQLite (SQLAlchemy ORM) | Léger pour le MVP, migration facile vers PostgreSQL |
| OCR | Tesseract (pytesseract) + fallback intelligent | Extraction réelle de texte depuis les images/PDF |
| Authentification | JWT (python-jose) + bcrypt | Standard industriel pour les API REST |
| Conteneurisation | Docker + docker-compose | Déploiement reproductible exigé par le cahier des charges |

---

## Prérequis

- **Python 3.10+**
- **Node.js 18+** et npm
- **Docker** et docker-compose (optionnel, pour le déploiement conteneurisé)
- **Tesseract OCR** (optionnel, le système fonctionne en mode fallback si absent)

---

## Installation et lancement (mode développement)

### 1. Backend

```bash
cd backend
pip install -r requirements.txt
python main.py
```

Le serveur démarre sur `http://localhost:8000`.  
La documentation interactive Swagger est accessible sur `http://localhost:8000/docs`.

### 2. Frontend

```bash
cd frontend
npm install
npm run dev
```

Le frontend démarre sur `http://localhost:5173`.

### 3. Comptes de démonstration

| Rôle | Email | Mot de passe |
|------|-------|-------------|
| Client | client@demo.com | client123 |
| Comptable | comptable@demo.com | comptable123 |
| Administrateur | admin@demo.com | admin123 |

---

## Lancement avec Docker

```bash
docker-compose up --build
```

L'application complète sera accessible sur `http://localhost:8000`.

---

## Structure du projet

```
plateforme/
├── backend/
│   ├── main.py              # Point d'entrée API FastAPI
│   ├── database.py           # Modèles SQLAlchemy + initialisation BDD
│   ├── auth.py               # Authentification JWT + RBAC
│   ├── ocr_engine.py         # Moteur d'extraction OCR (Tesseract + fallback)
│   ├── compliance.py         # Moteur de conformité paramétrable
│   ├── fraud_detector.py     # Détection de fraude + scoring explicable
│   └── requirements.txt      # Dépendances Python
├── frontend/
│   ├── src/
│   │   ├── pages/            # Pages React (Login, Dashboard, Capture, Admin)
│   │   ├── components/       # Composants réutilisables (Layout, etc.)
│   │   ├── context/          # Contexte d'authentification React
│   │   ├── api.ts            # Client API Axios configuré
│   │   ├── App.tsx           # Routage principal
│   │   └── index.css         # Charte graphique (dark mode, glassmorphism)
│   └── package.json
├── Dockerfile                # Image Docker multi-stage
├── docker-compose.yml        # Orchestration des services
├── .gitignore
└── README.md                 # Ce fichier
```

---

## Fonctionnalités implémentées (MVP)

### Capture & OCR
- Import de fichiers (drag & drop ou sélection)
- Extraction OCR réelle via Tesseract (avec fallback intelligent)
- Prévisualisation du document avec lien donnée-zone interactif
- Formulaire de correction et validation des données extraites

### Conformité
- Contrôle des champs obligatoires
- Vérification arithmétique TVA (HT + TVA = TTC)
- Validation de la date (non future)
- Vérification du format IBAN
- Règles activables/désactivables par l'administrateur

### Détection de fraude
- Changement d'IBAN suspect vs. annuaire officiel
- Fournisseur inconnu
- Montant anormalement élevé
- Doublons de factures
- Score de risque 0-100% avec justification explicable

### Sécurité & Traçabilité
- Authentification par JWT avec expiration
- Contrôle d'accès basé sur les rôles (RBAC)
- Journal d'audit horodaté (acteur, action, cible, IP)

---

## Scénarios de démonstration

1. **Facture légitime** — Upload STEG → OCR → Score faible → Validation comptable
2. **Fraude à l'IBAN** — Upload avec IBAN modifié → Alerte critique → Rejet
3. **Erreur de TVA** — Upload avec calcul incorrect → Non-conformité expliquée
4. **Fournisseur inconnu** — Upload d'un fournisseur hors référentiel → Risque modéré

---

*Document produit dans le cadre du WP4 — Secure Invoice AI*  
*Yassine Latrous / Juillet 2026*
