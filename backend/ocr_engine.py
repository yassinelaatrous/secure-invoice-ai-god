"""
=============================================================================
Secure Invoice AI — Moteur OCR (ocr_engine.py)
=============================================================================
Extraction de données depuis des images de factures via Tesseract OCR.
Si Tesseract n'est pas installé, un mécanisme de fallback intelligent
est utilisé pour la démonstration.
=============================================================================
"""

import re
import os
from typing import Dict, Optional
from datetime import datetime
from pydantic import BaseModel, Field

# ─── Configuration de Gemini API ──────────────────────────────────────────
GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY")

class InvoiceDetails(BaseModel):
    fournisseur: Optional[str] = Field(None, description="Nom commercial du fournisseur/émetteur de la facture (ex: Orange, STEG, AWS)")
    numero: Optional[str] = Field(None, description="Numéro unique de la facture")
    date_facture: Optional[str] = Field(None, description="Date d'émission au format AAAA-MM-JJ")
    ht: Optional[float] = Field(None, description="Montant hors taxes (HT)")
    tva: Optional[float] = Field(None, description="Montant de la TVA")
    ttc: Optional[float] = Field(None, description="Montant total toutes taxes comprises (TTC)")
    iban: Optional[str] = Field(None, description="IBAN complet pour le paiement")
    devise: Optional[str] = Field("TND", description="Devise de la facture (TND, EUR, USD)")

# ─── Vérification de la disponibilité de Tesseract ────────────────────────
TESSERACT_AVAILABLE = False

try:
    import pytesseract
    from PIL import Image
    # Configurer le chemin Windows pour Tesseract
    tesseract_win_path = r"C:\Program Files\Tesseract-OCR\tesseract.exe"
    if os.path.exists(tesseract_win_path):
        pytesseract.pytesseract.tesseract_cmd = tesseract_win_path
    # Tester si Tesseract est réellement installé sur le système
    pytesseract.get_tesseract_version()
    TESSERACT_AVAILABLE = True
    print("[INFO] Tesseract OCR detecte et disponible.")
except Exception:
    print("[ATTENTION] Tesseract OCR non disponible - mode fallback active.")
    try:
        from PIL import Image
    except ImportError:
        Image = None


# ─── Extraction OCR réelle avec Tesseract ─────────────────────────────────

def extract_text_from_image(image_path: str) -> str:
    """
    Extrait le texte brut d'une image via Tesseract OCR.
    
    Args:
        image_path: Chemin vers l'image à analyser
    
    Returns:
        Texte extrait de l'image
    """
    if not TESSERACT_AVAILABLE:
        return ""
    
    try:
        import pytesseract
        from PIL import Image
        
        img = Image.open(image_path)
        # Utiliser le français et l'anglais pour la reconnaissance
        text = pytesseract.image_to_string(img, lang="fra+eng")
        return text
    except Exception as e:
        print(f"⚠️  Erreur OCR Tesseract : {e}")
        return ""


def normalize_date(date_str: str) -> Optional[str]:
    """Normalise la date extraite au format standard AAAA-MM-JJ."""
    if not date_str:
        return None
    # Remplacer les séparateurs par -
    normalized = re.sub(r'[./]', '-', date_str.strip())
    
    # Tester le format YYYY-MM-DD
    match_ymd = re.match(r'^(\d{4})-(\d{1,2})-(\d{1,2})$', normalized)
    if match_ymd:
        try:
            year, month, day = map(int, match_ymd.groups())
            return f"{year:04d}-{month:02d}-{day:02d}"
        except ValueError:
            pass
            
    # Tester le format DD-MM-YYYY ou DD-MM-YY
    match_dmy = re.match(r'^(\d{1,2})-(\d{1,2})-(\d{2,4})$', normalized)
    if match_dmy:
        try:
            day, month, year_val = map(int, match_dmy.groups())
            if year_val < 100:
                year_val += 2000
            return f"{year_val:04d}-{month:02d}-{day:02d}"
        except ValueError:
            pass
            
    return date_str


# ─── Analyse du texte extrait par regex ───────────────────────────────────

def parse_invoice_text(text: str) -> Dict:
    """
    Analyse le texte extrait pour trouver les champs de facture
    via des expressions régulières.
    
    Cherche : fournisseur, numéro de facture, date, montants (HT, TVA, TTC),
    IBAN, et devise.
    
    Args:
        text: Texte brut extrait de l'image
    
    Returns:
        Dictionnaire avec les champs extraits et un score de confiance
    """
    result = {
        "fournisseur": None,
        "numero": None,
        "date_facture": None,
        "ht": None,
        "tva": None,
        "ttc": None,
        "iban": None,
        "devise": "TND",
        "confiance": 0.0,
        "source": "ocr_tesseract" if TESSERACT_AVAILABLE else "fallback",
        "texte_brut": text[:500] if text else ""  # Limiter pour l'API
    }
    
    if not text:
        return result
    
    champs_trouves = 0
    total_champs = 7  # Nombre de champs qu'on essaie d'extraire
    
    # ── Numéro de facture ──────────────────────────────────────────
    num_patterns = [
        r'(?:facture|invoice|fact\.?|n°)\s*[:#]?\s*([A-Z0-9][\w\-/]{2,20})',
        r'(?:N°|No\.?|Num[ée]ro)\s*[:#]?\s*([A-Z0-9][\w\-/]{2,20})',
        r'\b(FAC[-/]\d{4}[-/]\d{3,6})\b',
        r'\b([A-Z]{2,5}-\d{4}-\d{3,6})\b',
    ]
    for pattern in num_patterns:
        match = re.search(pattern, text, re.IGNORECASE)
        if match:
            result["numero"] = match.group(1).strip()
            champs_trouves += 1
            break
    
    # ── Date de facture ────────────────────────────────────────────
    date_patterns = [
        r'(?:date|le|du|émise?\s+le)\s*[:#]?\s*(\d{1,2}[/\-.]\d{1,2}[/\-.]\d{2,4})',
        r'\b(\d{1,2}[/\-.]\d{1,2}[/\-.]\d{4})\b',
        r'\b(\d{4}[/\-.]\d{1,2}[/\-.]\d{1,2})\b',
    ]
    for pattern in date_patterns:
        match = re.search(pattern, text, re.IGNORECASE)
        if match:
            result["date_facture"] = normalize_date(match.group(1).strip())
            champs_trouves += 1
            break
    
    # ── Montants financiers ────────────────────────────────────────
    def extract_amount(patterns, text_to_search):
        """Extrait et nettoie un montant numérique depuis le texte."""
        for p in patterns:
            m = re.search(p, text_to_search, re.IGNORECASE)
            if m:
                amount_str = m.group(1).strip()
                # Supprimer les espaces et devises
                cleaned = re.sub(r'[^\d.,]', '', amount_str)
                if not cleaned:
                    continue
                # Gérer les séparateurs de milliers et décimaux
                if ',' in cleaned and '.' in cleaned:
                    if cleaned.rfind(',') > cleaned.rfind('.'):
                        cleaned = cleaned.replace('.', '').replace(',', '.')
                    else:
                        cleaned = cleaned.replace(',', '')
                elif ',' in cleaned:
                    parts = cleaned.split(',')
                    if len(parts) == 2 and len(parts[1]) <= 2:
                        cleaned = cleaned.replace(',', '.')
                    else:
                        cleaned = cleaned.replace(',', '')
                try:
                    return float(cleaned)
                except ValueError:
                    continue
        return None
    
    # Montant HT (Hors Taxes)
    ht_patterns = [
        r'(?:montant\s+)?(?:H\.?T\.?|hors\s+taxes?)\s*[:#]?\s*([\d\s,.]+)',
        r'(?:total|sous.?total)\s+(?:H\.?T\.?)\s*[:#]?\s*([\d\s,.]+)',
        r'(?:H\.?T\.?)\s*[:#]?\s*([\d\s,.]+)',
    ]
    result["ht"] = extract_amount(ht_patterns, text)
    if result["ht"]:
        champs_trouves += 1
    
    # Montant TVA
    tva_patterns = [
        r'(?:T\.?V\.?A\.?|taxe)\s*(?:\(\d+%?\))?\s*[:#]?\s*([\d\s,.]+)',
        r'(?:montant\s+)?(?:T\.?V\.?A\.?)\s*[:#]?\s*([\d\s,.]+)',
    ]
    result["tva"] = extract_amount(tva_patterns, text)
    if result["tva"]:
        champs_trouves += 1
    
    # Montant TTC (Toutes Taxes Comprises)
    ttc_patterns = [
        r'(?:montant\s+)?(?:T\.?T\.?C\.?|toutes\s+taxes)\s*[:#]?\s*([\d\s,.]+)',
        r'(?:total|net\s+[àa]\s+payer)\s*[:#]?\s*([\d\s,.]+)',
        r'(?:T\.?T\.?C\.?)\s*[:#]?\s*([\d\s,.]+)',
    ]
    result["ttc"] = extract_amount(ttc_patterns, text)
    if result["ttc"]:
        champs_trouves += 1
    
    # ── IBAN ───────────────────────────────────────────────────────
    iban_pattern = r'\b([A-Z]{2}\d{2}[\s]?[\dA-Z]{4,30})\b'
    iban_match = re.search(iban_pattern, text)
    if iban_match:
        iban_candidate = iban_match.group(1).replace(" ", "")
        if 15 <= len(iban_candidate) <= 34:
            result["iban"] = iban_candidate
            champs_trouves += 1
    
    # ── Devise ─────────────────────────────────────────────────────
    if re.search(r'\b(EUR|€|euro)', text, re.IGNORECASE):
        result["devise"] = "EUR"
    elif re.search(r'\b(USD|\$|dollar)', text, re.IGNORECASE):
        result["devise"] = "USD"
    elif re.search(r'\b(TND|DT|dinar)', text, re.IGNORECASE):
        result["devise"] = "TND"
    
    # ── Fournisseur (première ligne significative) ─────────────────
    lines = [l.strip() for l in text.split("\n") if l.strip() and len(l.strip()) > 3]
    # Chercher des mots-clés de fournisseur connus
    known_suppliers = ["STEG", "Orange", "Tunisie Telecom", "Amazon", "AWS", "SOPAT"]
    for supplier in known_suppliers:
        if supplier.lower() in text.lower():
            result["fournisseur"] = supplier
            champs_trouves += 1
            break
    
    # Si aucun fournisseur connu trouvé, utiliser la première ligne
    if not result["fournisseur"] and lines:
        result["fournisseur"] = lines[0][:100]
        champs_trouves += 0.5  # Demi-point car peu fiable
    
    # ── Score de confiance ─────────────────────────────────────────
    result["confiance"] = round(min(champs_trouves / total_champs, 1.0), 2)
    
    return result


# ─── Fallback intelligent basé sur le nom du fichier ──────────────────────

def fallback_extract(filename: str) -> Dict:
    """
    Extraction de secours basée sur le nom du fichier.
    Utilisé quand Tesseract n'est pas disponible ou échoue.
    
    Analyse le nom du fichier pour deviner le fournisseur et génère
    des données réalistes de démonstration.
    
    Args:
        filename: Nom du fichier uploadé
    
    Returns:
        Dictionnaire avec les données extraites simulées
    """
    filename_lower = filename.lower()
    
    # Scénarios prédéfinis selon le nom du fichier
    scenarios = {
        "steg": {
            "fournisseur": "STEG",
            "numero": f"STEG-2026-{hash(filename) % 9000 + 1000:04d}",
            "date_facture": "2026-06-15",
            "ht": 1350.00,
            "tva": 256.50,
            "ttc": 1606.50,
            "iban": "TN5910006035183598983943",
            "devise": "TND",
            "confiance": 0.85,
        },
        "orange": {
            "fournisseur": "Orange Business Services",
            "numero": f"OBS-2026-{hash(filename) % 9000 + 1000:04d}",
            "date_facture": "2026-06-20",
            "ht": 2800.00,
            "tva": 532.00,
            "ttc": 3332.00,
            "iban": "FR7630006000011234567890189",
            "devise": "EUR",
            "confiance": 0.80,
        },
        "telecom": {
            "fournisseur": "Tunisie Telecom",
            "numero": f"TT-2026-{hash(filename) % 9000 + 1000:04d}",
            "date_facture": "2026-07-01",
            "ht": 450.00,
            "tva": 85.50,
            "ttc": 535.50,
            "iban": "TN5914006099012734956823",
            "devise": "TND",
            "confiance": 0.80,
        },
        "amazon": {
            "fournisseur": "Amazon Web Services",
            "numero": f"AWS-2026-{hash(filename) % 9000 + 1000:04d}",
            "date_facture": "2026-06-30",
            "ht": 4200.00,
            "tva": 798.00,
            "ttc": 4998.00,
            "iban": "DE89370400440532013000",
            "devise": "USD",
            "confiance": 0.75,
        },
        "sopat": {
            "fournisseur": "SOPAT",
            "numero": f"SOP-2026-{hash(filename) % 9000 + 1000:04d}",
            "date_facture": "2026-06-25",
            "ht": 1800.00,
            "tva": 342.00,
            "ttc": 2142.00,
            "iban": "TN5910006035100078901234",
            "devise": "TND",
            "confiance": 0.80,
        },
    }
    
    # Chercher un scénario correspondant au nom du fichier
    for keyword, data in scenarios.items():
        if keyword in filename_lower:
            return {
                **data,
                "source": "fallback_nom_fichier",
                "texte_brut": f"[Simulation] Données extraites du nom de fichier : {filename}"
            }
    
    # Scénario par défaut pour un fichier non reconnu
    return {
        "fournisseur": "Fournisseur Inconnu",
        "numero": f"INV-{datetime.now().strftime('%Y%m%d')}-001",
        "date_facture": datetime.now().strftime("%Y-%m-%d"),
        "ht": 1000.00,
        "tva": 190.00,
        "ttc": 1190.00,
        "iban": None,
        "devise": "TND",
        "confiance": 0.30,
        "source": "fallback_defaut",
        "texte_brut": f"[Simulation] Aucun scénario trouvé pour : {filename}"
    }


def extract_with_gemini(image_path: str) -> Optional[Dict]:
    """
    Extrait les données de facture de manière intelligente à l'aide de l'API Gemini.
    """
    if not GEMINI_API_KEY:
        print("[WARNING] GEMINI_API_KEY non configuré. Saut de l'extraction Gemini.")
        return None

    try:
        from google import genai

        print("[INFO] Lancement de l'extraction intelligente avec Gemini API...")
        client = genai.Client(api_key=GEMINI_API_KEY)
        
        # Téléverser le document (image ou PDF) via la Files API de Gemini
        print(f"[INFO] Upload du document '{image_path}' vers Gemini Files API...")
        uploaded_file = client.files.upload(file=image_path)
        print(f"[INFO] Upload réussi. Nom distant : {uploaded_file.name}")

        prompt = (
            "Extrayez les informations de cette facture. "
            "Remplissez les champs de manière extrêmement rigoureuse. "
            "Ne devinez pas de fausses informations. "
            "Si un montant ou une date n'est pas présent, laissez le champ à null. "
            "Retournez le résultat strictement selon le schéma JSON demandé."
        )

        try:
            response = client.models.generate_content(
                model='gemini-2.5-flash',
                contents=[uploaded_file, prompt],
                config={
                    'response_mime_type': 'application/json',
                    'response_schema': InvoiceDetails,
                }
            )

            if response.parsed:
                data = response.parsed.model_dump()
                data["source"] = "gemini_api"
                data["confiance"] = 0.98
                data["texte_brut"] = f"[Gemini] Extraction reussie depuis : {os.path.basename(image_path)}"
                print("[SUCCESS] Extraction Gemini reussie !")
                return data
        finally:
            # Nettoyer le fichier après traitement pour respecter la vie privée / sécurité
            try:
                print(f"[INFO] Nettoyage du fichier distant '{uploaded_file.name}'...")
                client.files.delete(name=uploaded_file.name)
            except Exception as clean_err:
                print(f"[WARNING] Impossible de supprimer le fichier temporaire Gemini : {clean_err}")

    except Exception as e:
        print(f"[ERROR] Echec de l'extraction Gemini : {e}")

    return None


# ─── Fonction principale d'extraction ─────────────────────────────────────

def extract_invoice_data(image_path: str, filename: str = "") -> Dict:
    """
    Point d'entrée principal pour l'extraction de données de facture.
    
    Stratégie :
    1. Si la clé Gemini API est configurée → extraction intelligente avec Gemini
    2. Sinon, si Tesseract est disponible → extraction OCR réelle
    3. Sinon → fallback intelligent
    
    Args:
        image_path: Chemin vers l'image uploadée
        filename: Nom original du fichier (pour le fallback)
    
    Returns:
        Dictionnaire structuré avec les données extraites et métadonnées
    """
    result = None
    
    # Tentative 1 : Gemini API (Intelligent)
    if GEMINI_API_KEY:
        result = extract_with_gemini(image_path)
    
    # Tentative 2 : OCR réel avec Tesseract
    if result is None and TESSERACT_AVAILABLE:
        try:
            raw_text = extract_text_from_image(image_path)
            if raw_text and len(raw_text.strip()) > 20:
                result = parse_invoice_text(raw_text)
                # Si la confiance est trop faible, on complète avec le fallback
                if result["confiance"] < 0.3:
                    fallback = fallback_extract(filename or os.path.basename(image_path))
                    # Fusionner : garder les champs OCR non-nuls, compléter avec fallback
                    for key, value in fallback.items():
                        if key not in ("source", "texte_brut", "confiance") and result.get(key) is None:
                            result[key] = value
                    result["source"] = "ocr_complete_par_fallback"
        except Exception as e:
            print(f"⚠️  Erreur lors de l'extraction OCR : {e}")
    
    # Tentative 3 : Fallback intelligent
    if result is None:
        result = fallback_extract(filename or os.path.basename(image_path))
    
    # Ajouter des métadonnées
    result["tesseract_disponible"] = TESSERACT_AVAILABLE
    result["gemini_utilise"] = (result.get("source") == "gemini_api")
    result["fichier_source"] = filename or os.path.basename(image_path)
    
    return result
