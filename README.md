# 🌌 CEO.IT — Secure Invoice AI 🚀

> **Intelligence-driven Invoice Processing, Security Auditing, and Multi-role Financial Operations Dashboard.**  
> *Stage PFE 2026 — Plateforme Peak Dark & Fluid Design*

---

<p align="center">
  <img src="https://img.shields.io/badge/Gemini%20AI-2.5%20Flash-blue?style=for-the-badge&logo=google-gemini&logoColor=white" />
  <img src="https://img.shields.io/badge/React-18%20(Vite)-61DAFB?style=for-the-badge&logo=react&logoColor=black" />
  <img src="https://img.shields.io/badge/FastAPI-Python%203.11-009688?style=for-the-badge&logo=fastapi&logoColor=white" />
  <img src="https://img.shields.io/badge/Docker-Multi--stage-2496ED?style=for-the-badge&logo=docker&logoColor=white" />
  <img src="https://img.shields.io/badge/Theme-Mytasky%20Dark-orange?style=for-the-badge" />
</p>

---

## 🌟 Overview

**CEO.IT (Secure Invoice AI)** is a production-grade smart platform designed to streamline accounts payable and auditing workflows. It automates financial document ingestion, extracts highly structured accounting data using Google Gemini API, enforces localized compliance policies, detects invoice-related fraud, and coordinates operations between **Clients**, **Accountants**, and **Administrators** in real-time.

### 🎭 Beautiful Fluid Design & Branding
- **Animated Silver Waves**: The login screen features a hardware-accelerated, floating parallax wave background simulating liquid metal flow.
- **Brand Identity**: Replaces standard placeholders with a glowing tech **Hexagonal AI Node Logo** dynamically animated in CSS.
- **Mytasky Theme**: High-contrast, deeply rounded (`32px`) dashboard cards, vibrant status dots, and neon accents.

---

## ⚡ Core Features

### 1. 🤖 3-Tier Hybrid OCR Ingestion Engine
- **Tier 1 (Gemini AI)**: Processes PDFs, PNGs, and JPGs using the `google-genai` SDK and structured JSON outputs (`gemini-2.5-flash`). Correctly extracts Tunisian dinar (`TND` / `DT`) values down to 3 decimal places (millimes) and formats invoice dates as `YYYY-MM-DD`.
- **Tier 2 (Tesseract fallback)**: Local OCR Engine triggers if Gemini credentials or internet calls fail. Uses pre-trained French datasets and custom regex patterns.
- **Tier 3 (Demo fallback)**: Gracefully handles document capture failure to maintain system availability.

### 2. 📱 Parallax Mobile Upload Pairing
- Generates a **unique QR code session** on the desktop capture panel.
- Users scan the QR code to pair their smartphones instantly.
- The paired mobile interface lets users shoot invoices with their phone cameras and upload them directly to the active desktop session.

### 3. 🔍 Adjustable Compliance Rules (Admin)
The compliance engine runs four configurable checks against incoming invoices:
*   `CHAMPS_OBLIGATOIRES`: Enforces values for Supplier Name, Invoice ID, Date, and Total.
*   `COHERENCE_TVA`: Audits calculation values (`HT + TVA == TTC` within a `1.0` rounding tolerance).
*   `VALIDITE_DATE`: Flags invoices dated in the future.
*   `IBAN_VALIDE`: Performs character length validation for Bank IDs.

### 4. 🛡️ Risk & Fraud Detection Score (0-100)
Invoices are dynamically analyzed against five risk vectors:
- **IBAN Hijack (+65 points)**: Flags if the extracted IBAN deviates from the vendor's registered bank profile.
- **Untrusted Supplier (+40 points)**: Supplier is not in the certified directory.
- **Supplier Double Entry (+30 points)**: Exact invoice number already exists.
- **Anomalous Amount (+25 points)**: Total amount is 3x higher than the vendor's running average.
- **Date-Amount Collision (+20 points)**: Duplicated financial values matching an existing date.

---

## 📁 Technical Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                       React 18 Frontend                     │
│                 (Vite + TypeScript + CSS Grid)              │
│                                                             │
│  ┌───────────┐   ┌─────────────┐   ┌────────────┐   ┌───────┐  │
│  │ Login     │   │ Capture OCR │   │ Invoices   │   │ Admin │  │
│  │ (Wavy bg) │   │ (Mobile QR) │   │ (Filter)   │   │ Logs  │  │
│  └───────────┘   └─────────────┘   └────────────┘   └───────┘  │
└──────────────────────────────┬──────────────────────────────┘
                               │ JSON REST API
┌──────────────────────────────┴──────────────────────────────┐
│                       FastAPI Backend                       │
│                                                             │
│  ┌──────────────────┐  ┌──────────────────┐  ┌───────────┐  │
│  │ ocr_engine.py    │  │ compliance.py    │  │ fraud.py  │  │
│  │ (Gemini/Tess.)   │  │ (Admin Rules)    │  │ (Scoring) │  │
│  └──────────────────┘  └──────────────────┘  └───────────┘  │
│  ┌──────────────────┐  ┌──────────────────┐                 │
│  │ auth.py (JWT)    │  │ database.py      │                 │
│  │ (RBAC Guards)    │  │ (SQLAlchemy ORM) │                 │
│  └──────────────────┘  └──────────────────┘                 │
└──────────────────────────────┬──────────────────────────────┘
                               │ SQLite DB file
                       ┌───────┴───────┐
                       │   SQLite DB   │
                       │ (secure_inv)  │
                       └───────────────┘
```

---

## 🚀 Quick Start & Installation

### Prerequisites
- Install **[Docker Desktop](https://www.docker.com/products/docker-desktop/)** (Recommended) or **[NodeJS 20+](https://nodejs.org/)** & **[Python 3.11](https://www.python.org/)**.
- Get a free **Gemini API Key** from [Google AI Studio](https://aistudio.google.com/).

---

### Method A: Single Command Run (Docker Compose) 🐳

This is the easiest and most production-ready method. Docker sets up the local SQLite database, builds the production bundles, installs Tesseract OCR dependencies, and spins up the environment.

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yassinelaatrous/secure-invoice-ai.git
   cd secure-invoice-ai
   ```

2. **Configure your environment variables**:
   Create a `.env` file in the root directory (or inject it directly):
   ```bash
   # On Linux/macOS
   echo "GEMINI_API_KEY=your_google_studio_api_key_here" > .env
   
   # On Windows (PowerShell)
   New-Item -Path .env -Value "GEMINI_API_KEY=your_google_studio_api_key_here"
   ```

3. **Start the containers**:
   ```bash
   docker-compose up --build
   ```

4. **Access the application**:
   - Web App UI: **[http://localhost:8000](http://localhost:8000)** (serves both React & API endpoints)
   - Interactive API Swagger docs: **[http://localhost:8000/docs](http://localhost:8000/docs)**

---

### Method B: Local Development Setup (No Docker) 💻

If you prefer to run the code directly on your local machine:

#### 1. Backend Setup
1. Navigate to the backend directory:
   ```bash
   cd backend
   ```
2. Create and activate a python virtual environment:
   ```bash
   python -m venv venv
   # On Windows:
   .\venv\Scripts\activate
   # On macOS/Linux:
   source venv/bin/activate
   ```
3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
4. Create a `.env` file in `backend/.env` containing your Gemini API key:
   ```env
   GEMINI_API_KEY=your_google_studio_api_key_here
   ```
5. Launch the backend:
   ```bash
   python -m uvicorn main:app --port 8000 --reload
   ```

#### 2. Frontend Setup
1. Open a new terminal and navigate to the frontend directory:
   ```bash
   cd frontend
   ```
2. Install npm packages:
   ```bash
   npm install
   ```
3. Start the Vite development server:
   ```bash
   npm run dev
   ```
4. Open your browser at: **[http://localhost:3000](http://localhost:3000)**.

---

## 👥 Demo Logins

The application starts with standard preloaded entities and users for validation. You can swap roles instantly from the top header widget.

| Role | Username | Password | Dashboard Type |
|---|---|---|---|
| **Administrator** | `admin@demo.com` | `admin123` | Control Audit Logs, toggle system rules, review security compliance metrics. |
| **Accountant** | `comptable@demo.com` | `comptable123` | Assign folders, audit vendor files, change invoice approval statuses. |
| **Client Owner** | `client@demo.com` | `client123` | Upload personal documents, verify transactions, view payment timelines. |

---

## 🛡️ Security Implementations
- **Strict JWT RBAC**: Every REST endpoint is guarded via a signature check (`HS256`) and specific role permissions.
- **Privacy-safe API calls**: Temporary files sent to Google via the Gemini API are automatically deleted from Google’s file systems immediately after structured JSON parsing completes.
- **Passwords Encryption**: Uses PBKDF2 hashing functions.
- **Audit Logs**: Irreversible system events list capturing client uploads, status mutations, and rules adjustment.

---
*Developed as a Graduation PFE 2026 Project by Yassine Laatrous.*
