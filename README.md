# Secure Invoice AI — Plateforme Intelligente de Gestion de Factures

> **Module WP4** — Extraction, Conformite et Detection de Fraude  
> Responsable : **Yassine Laatrous**  
> Stage PFE 2026

---

## Presentation du Projet

Secure Invoice AI est une plateforme web de gestion intelligente de factures electroniques. Elle automatise l'extraction de donnees depuis des documents scannees (images, PDF) grace a l'intelligence artificielle (Google Gemini API), puis effectue des controles de conformite comptable et detecte les tentatives de fraude en temps reel.

### Problematique

Dans le processus comptable traditionnel, la saisie manuelle des factures est :
- **Lente** : un comptable traite ~50 factures/jour manuellement
- **Sujette aux erreurs** : fautes de frappe, inversions de chiffres
- **Vulnerable a la fraude** : modification d'IBAN, doublons, fournisseurs fictifs

### Solution

Cette plateforme resout ces problemes grace a un pipeline intelligent en 3 etapes :

```
Document (PDF/Image) → Extraction IA (Gemini) → Conformite + Fraude → Base de donnees
```

---

## Architecture Technique

```
┌─────────────────────────────────────────────────────────┐
│                    Frontend React                        │
│              (Vite + TypeScript + CSS)                   │
│                                                          │
│  ┌──────────┐  ┌──────────┐  ┌───────┐  ┌───────────┐  │
│  │ Login    │  │ Capture  │  │ Liste │  │   Admin   │  │
│  │ Page     │  │ OCR Page │  │ Fact. │  │   Panel   │  │
│  └──────────┘  └──────────┘  └───────┘  └───────────┘  │
└─────────────────────┬───────────────────────────────────┘
                      │ API REST (JSON)
┌─────────────────────┴───────────────────────────────────┐
│                  Backend FastAPI                         │
│                                                          │
│  ┌──────────────┐  ┌───────────────┐  ┌──────────────┐  │
│  │ ocr_engine   │  │ compliance    │  │ fraud_detect │  │
│  │ (Gemini API) │  │ (4 regles)    │  │ (IBAN/doub.) │  │
│  └──────────────┘  └───────────────┘  └──────────────┘  │
│  ┌──────────────┐  ┌───────────────┐                    │
│  │ auth (JWT)   │  │ database      │                    │
│  │ RBAC 3 roles │  │ (SQLAlchemy)  │                    │
│  └──────────────┘  └───────────────┘                    │
└─────────────────────┬───────────────────────────────────┘
                      │
              ┌───────┴───────┐
              │  SQLite DB    │
              │ (secure_inv.) │
              └───────────────┘
```

---

## Stack Technique

| Couche       | Technologie              | Justification                                         |
|-------------|--------------------------|-------------------------------------------------------|
| Frontend    | React 18 + TypeScript    | Typage statique, ecosysteme mature, composants reactifs |
| Build Tool  | Vite                     | Hot reload rapide, build optimise                      |
| Backend     | Python FastAPI           | Async natif, validation Pydantic, docs auto (Swagger)  |
| IA/OCR      | Google Gemini 2.5 Flash  | Vision multimodale, extraction structuree JSON         |
| OCR Backup  | Tesseract OCR            | Moteur OCR local, fonctionne hors-ligne                |
| Auth        | JWT + RBAC               | Tokens signes HS256, 3 roles (client/comptable/admin)  |
| BDD         | SQLite + SQLAlchemy ORM  | Leger, zero config, ORM complet                        |
| Deploy      | Docker multi-stage       | Image optimisee, reproductible                         |

---

## Modules Backend — Explication Detaillee

### 1. `ocr_engine.py` — Moteur d'Extraction Intelligent

**Role** : Convertir un document (image ou PDF) en donnees structurees JSON.

**Strategie en 3 niveaux** :

| Priorite | Methode         | Quand ?                    | Confiance |
|----------|-----------------|----------------------------|-----------|
| 1        | Gemini API      | Cle API disponible         | ~95%      |
| 2        | Tesseract + Regex | Gemini echoue            | ~40-70%   |
| 3        | Fallback minimal | Tout echoue               | ~10%      |

**Comment fonctionne Gemini API ici :**
1. Le fichier (PDF ou image) est uploade vers l'API Files de Google
2. Gemini 2.5 Flash analyse visuellement le document (vision multimodale)
3. Un prompt expert en comptabilite guide l'extraction
4. La reponse est validee par un schema Pydantic (typage strict)
5. Le fichier temporaire est supprime de Google apres traitement (securite)

**Schema Pydantic** : Definit les champs attendus (fournisseur, numero, date, montants HT/TVA/TTC, IBAN, devise, lignes de facturation). Gemini est contraint de retourner exactement ce format JSON.

### 2. `compliance.py` — Moteur de Conformite

**Role** : Verifier qu'une facture respecte les regles comptables.

**4 regles implementees** (activables/desactivables par un admin) :

| Code                | Description                                              |
|---------------------|----------------------------------------------------------|
| CHAMPS_OBLIGATOIRES | Fournisseur, numero, date et TTC doivent etre renseignes |
| COHERENCE_TVA       | Verifie que HT + TVA = TTC (tolerance 0.05)              |
| VALIDITE_DATE       | La date ne doit pas etre dans le futur                   |
| IBAN_VALIDE         | L'IBAN doit avoir entre 15 et 34 caracteres              |

### 3. `fraud_detector.py` — Detection de Fraude

**Role** : Calculer un score de risque (0-100) pour chaque facture.

**Criteres de detection** :

| Verification              | Points | Description                                    |
|---------------------------|--------|------------------------------------------------|
| IBAN modifie              | +65    | L'IBAN ne correspond pas au fournisseur connu  |
| Fournisseur inconnu       | +40    | Pas dans l'annuaire de confiance               |
| Montant anormal           | +25    | Depasse 3x la moyenne mensuelle                |
| Doublon numero            | +30    | Meme numero de facture deja enregistre          |
| Doublon montant/date      | +20    | Meme montant a une date similaire               |

### 4. `auth.py` — Authentification et Autorisation

**Role** : Securiser l'API avec des tokens JWT et un controle d'acces RBAC.

- **JWT (JSON Web Token)** : Token signe avec HS256, expire apres 60 minutes
- **RBAC (Role-Based Access Control)** : 3 roles avec permissions differentes
- **Hachage** : Mots de passe haches avec PBKDF2-SHA256 (via passlib)

| Role      | Permissions                                          |
|-----------|------------------------------------------------------|
| client    | Voir ses propres factures, uploader des documents    |
| comptable | Voir toutes les factures, modifier les statuts       |
| admin     | Tout + gestion des regles + journal d'audit          |

### 5. `database.py` — Modeles et Initialisation

**Role** : Definir la structure de la base de donnees et les donnees de demonstration.

**Modeles SQLAlchemy** :
- `Utilisateur` : id, nom, email, mot_de_passe_hash, role, actif
- `Facture` : donnees financieres + resultats conformite + score fraude
- `Fournisseur` : annuaire de confiance avec IBAN officiel
- `RegleConformite` : regles activables/desactivables
- `AuditLog` : journal de tracabilite de toutes les actions

---

## Installation et Demarrage

### Prerequis

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installe et lance
- [Git](https://git-scm.com/) installe
- Une cle API Gemini (gratuite sur [Google AI Studio](https://aistudio.google.com/))

### Etapes

```bash
# 1. Cloner le depot
git clone https://github.com/yassinelaatrous/secure-invoice-ai-god.git
cd secure-invoice-ai-god

# 2. Configurer la cle API Gemini
echo GEMINI_API_KEY=votre_cle_ici > backend/.env

# 3. Construire et lancer avec Docker
docker-compose up --build

# 4. Ouvrir dans le navigateur
# http://localhost:8000
```

### Comptes de Demonstration

| Role      | Email              | Mot de passe   |
|-----------|--------------------|----------------|
| Admin     | admin@demo.com     | admin123       |
| Comptable | comptable@demo.com | comptable123   |
| Client    | client@demo.com    | client123      |

---

## Utilisation

### Capture OCR (Upload de Facture)

1. Se connecter avec un compte (ex: `admin@demo.com` / `admin123`)
2. Aller dans **Capture OCR** dans le menu
3. Cliquer sur la zone d'upload et selectionner une facture (PDF, PNG ou JPG)
4. Cliquer sur **Lancer l'OCR**
5. L'IA Gemini analyse le document et remplit automatiquement les champs :
   - Fournisseur, Numero, Date
   - Montants HT, TVA, TTC
   - IBAN, Devise
6. Verifier les donnees puis cliquer sur **Verifier la conformite & Enregistrer**
7. Le systeme effectue automatiquement :
   - Controle de conformite (4 regles)
   - Detection de fraude (score 0-100)
   - Enregistrement + log d'audit

### Tableau de Bord

Affiche un resume : nombre de factures, statuts, alertes de fraude.

### Administration

Accessible uniquement aux admins :
- Activer/desactiver les regles de conformite
- Consulter le journal d'audit complet

---

## API REST — Endpoints

| Methode | Endpoint                     | Description                    | Roles autorises     |
|---------|------------------------------|--------------------------------|---------------------|
| POST    | `/api/auth/login`            | Connexion (retourne JWT)       | Public              |
| GET     | `/api/auth/me`               | Utilisateur courant            | Tous (authentifie)  |
| GET     | `/api/factures`              | Liste des factures             | Tous                |
| GET     | `/api/factures/{id}`         | Detail d'une facture           | Tous                |
| POST    | `/api/factures`              | Creer une facture              | Tous                |
| PUT     | `/api/factures/{id}/statut`  | Modifier le statut             | Comptable, Admin    |
| POST    | `/api/upload`                | Upload + extraction OCR        | Tous                |
| GET     | `/api/audit`                 | Journal d'audit                | Admin               |
| GET     | `/api/regles`                | Regles de conformite           | Tous                |
| PUT     | `/api/regles/{id}`           | Activer/desactiver une regle   | Admin               |
| GET     | `/api/fournisseurs`          | Liste des fournisseurs         | Tous                |

---

## Structure du Projet

```
secure-invoice-ai-god/
├── backend/
│   ├── main.py              # Point d'entree FastAPI + routes API
│   ├── ocr_engine.py        # Moteur OCR (Gemini + Tesseract + Fallback)
│   ├── compliance.py        # Moteur de conformite (4 regles)
│   ├── fraud_detector.py    # Detection de fraude (score 0-100)
│   ├── auth.py              # JWT + RBAC (3 roles)
│   ├── database.py          # Modeles SQLAlchemy + init demo
│   ├── requirements.txt     # Dependances Python
│   └── .env                 # Cle API Gemini (non versionnee)
├── frontend/
│   ├── src/
│   │   ├── pages/           # Pages React (Login, Capture, Liste, Admin)
│   │   ├── components/      # Composants reutilisables
│   │   ├── context/         # Contexte React (auth state)
│   │   └── api.ts           # Client Axios configure
│   ├── package.json
│   └── vite.config.ts
├── Dockerfile               # Build multi-stage (Node + Python)
├── docker-compose.yml       # Orchestration Docker
├── README.md                # Ce fichier
└── .gitignore
```

---

## Securite

- **Mots de passe** : Haches avec PBKDF2-SHA256 (jamais stockes en clair)
- **Tokens JWT** : Signes HS256, expirent apres 60 minutes
- **RBAC** : Controle d'acces par role sur chaque endpoint
- **Fichiers Gemini** : Supprimes automatiquement apres extraction
- **Cle API** : Stockee dans `.env` (exclue de Git par `.gitignore`)
- **Audit** : Chaque action est tracee dans le journal d'audit

---

*Projet realise dans le cadre du stage PFE 2026 — Yassine Laatrous*
