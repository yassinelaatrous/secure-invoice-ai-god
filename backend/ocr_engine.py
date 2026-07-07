"""
=============================================================================
Secure Invoice AI — Moteur OCR (ocr_engine.py)
=============================================================================
Stratégie d'extraction à 3 niveaux pour les factures numérisées :

  1. Gemini AI (prioritaire) — Utilise l'API Gemini Files pour envoyer
     le document complet (image ou PDF) et obtenir une extraction
     structurée via un LLM multimodal. Confiance élevée (~0.95).

  2. Tesseract OCR + regex (fallback) — Si Gemini est indisponible ou
     échoue, on tente une reconnaissance optique locale avec Tesseract
     puis on parse le texte brut via des expressions régulières calibrées
     pour les factures tunisiennes et françaises.

  3. Fallback minimal — Si tout échoue, retourne un dictionnaire vide
     avec des valeurs null et une confiance très faible (0.1), sans
     aucune donnée inventée.

Le module est conçu pour être autonome : il gère sa propre connexion
à l'API Gemini (clé lue depuis l'environnement ou décodée en base64),
sa détection de Tesseract, et ses schémas Pydantic.
=============================================================================
"""

import re
import os
import base64
from typing import Dict, Optional
from datetime import datetime
from pydantic import BaseModel, Field


# =============================================================================
# Configuration de la clé API Gemini
# =============================================================================
# La clé est lue depuis la variable d'environnement GEMINI_API_KEY (définie
# par load_env() dans main.py ou par Docker). Si elle est absente, on décode
# un fallback base64 pour que le conteneur Docker fonctionne immédiatement
# sans configuration manuelle.
# =============================================================================

_KEY_B64: str = "QVEuQWI4Uk42Slp0ZlRyZW9HdnctdFZRam5Sc0Z0bVFtczBab05KLUZsdlFCX0pvV1ljSXc="

GEMINI_API_KEY: Optional[str] = os.environ.get("GEMINI_API_KEY")
if not GEMINI_API_KEY:
    try:
        GEMINI_API_KEY = base64.b64decode(_KEY_B64).decode("utf-8")
    except Exception:
        GEMINI_API_KEY = None


# =============================================================================
# Schéma Pydantic v2 — Structure riche pour les données de facture
# =============================================================================
# On utilise des modèles Pydantic pour deux raisons :
#   1. Servir de response_schema à Gemini (structured output)
#   2. Valider et documenter les données extraites côté backend
# LineItem capture les lignes de facturation individuelles quand elles
# sont visibles sur le document (utile pour les factures détaillées).
# =============================================================================

class LineItem(BaseModel):
    """Représente une ligne de facturation individuelle sur une facture."""

    description: Optional[str] = None
    quantity: Optional[float] = None
    unit_price: Optional[float] = None
    tax_amount: Optional[float] = None
    line_total: Optional[float] = None


class InvoiceData(BaseModel):
    """
    Schéma complet d'une facture extraite.

    Tous les champs sont optionnels car l'extraction peut être partielle
    selon la qualité du document ou la méthode utilisée. La devise
    par défaut est TND (Dinar Tunisien) car la plateforme cible
    principalement le marché tunisien.
    """

    fournisseur: Optional[str] = Field(None, description="Nom du fournisseur")
    numero: Optional[str] = Field(None, description="Numero de facture")
    date_facture: Optional[str] = Field(None, description="Date au format AAAA-MM-JJ")
    ht: Optional[float] = Field(None, description="Montant hors taxes")
    tva: Optional[float] = Field(None, description="Montant TVA")
    ttc: Optional[float] = Field(None, description="Montant TTC")
    iban: Optional[str] = Field(None, description="IBAN")
    devise: Optional[str] = Field("TND", description="Devise")
    items: Optional[list[LineItem]] = Field(None, description="Lignes de facturation")


# =============================================================================
# Vérification de la disponibilité de Tesseract OCR
# =============================================================================
# On tente l'import et la détection au chargement du module pour éviter
# de vérifier à chaque appel. Sur les environnements Docker/serveur sans
# Tesseract installé, cela bascule silencieusement vers les autres méthodes.
# =============================================================================

TESSERACT_AVAILABLE: bool = False

try:
    import pytesseract
    from PIL import Image

    # Chemin Windows standard pour Tesseract
    tesseract_win_path: str = r"C:\Program Files\Tesseract-OCR\tesseract.exe"
    if os.path.exists(tesseract_win_path):
        pytesseract.pytesseract.tesseract_cmd = tesseract_win_path

    pytesseract.get_tesseract_version()
    TESSERACT_AVAILABLE = True
    print("[INFO] Tesseract OCR detecte et disponible.")
except Exception:
    print("[WARNING] Tesseract OCR non disponible - mode fallback active.")
    try:
        from PIL import Image
    except ImportError:
        Image = None  # type: ignore[assignment, misc]


# =============================================================================
# Extraction de texte brut via Tesseract
# =============================================================================

def extract_text_from_image(image_path: str) -> str:
    """
    Extrait le texte brut d'une image via Tesseract OCR.

    Cette fonction est le premier maillon de la chaîne Tesseract :
    elle produit du texte brut qui sera ensuite analysé par
    parse_invoice_text() pour en extraire les champs structurés.

    On utilise les langues fra+eng car les factures tunisiennes
    mélangent souvent français et anglais (surtout les termes
    comptables comme HT, TVA, TTC).

    Args:
        image_path: Chemin absolu vers l'image à analyser.

    Returns:
        Texte brut extrait, ou chaîne vide si Tesseract est
        indisponible ou si l'extraction échoue.
    """
    if not TESSERACT_AVAILABLE:
        return ""

    try:
        import pytesseract
        from PIL import Image as PILImage

        img = PILImage.open(image_path)
        text: str = pytesseract.image_to_string(img, lang="fra+eng")
        return text
    except Exception as e:
        print(f"[ERROR] Erreur OCR Tesseract : {e}")
        return ""


# =============================================================================
# Normalisation de date
# =============================================================================

def normalize_date(date_str: str) -> Optional[str]:
    """
    Normalise une date extraite au format standard AAAA-MM-JJ.

    Les factures utilisent des formats variés (DD/MM/YYYY, DD.MM.YY,
    décrite en lettres en français, etc.). Cette fonction uniformise vers
    ISO 8601 pour garantir la cohérence dans la base de données.

    Args:
        date_str: Date brute extraite du document.

    Returns:
        Date normalisée au format AAAA-MM-JJ, ou la chaîne originale
        si aucun format reconnu n'est détecté.
    """
    if not date_str:
        return None

    date_clean = date_str.strip().lower()
    
    # Dictionnaire des mois en français pour la conversion littérale
    months_fr = {
        "jan": 1, "janv": 1, "janvier": 1,
        "fev": 2, "fév": 2, "fevrier": 2, "février": 2,
        "mar": 3, "mars": 3,
        "avr": 4, "avril": 4,
        "mai": 5,
        "jui": 6, "juin": 6,
        "jul": 7, "juil": 7, "juillet": 7,
        "aou": 8, "aoû": 8, "aout": 8, "août": 8,
        "sep": 9, "sept": 9, "septembre": 9,
        "oct": 10, "octobre": 10,
        "nov": 11, "novembre": 11,
        "dec": 12, "déc": 12, "decembre": 12, "décembre": 12
    }

    # Supprimer les points (ex: "nov." -> "nov")
    date_clean = date_clean.replace(".", "")

    # Match format littéral : "29 mai 2026", "29-mai-2026", "29/mai/2026"
    match_literal = re.search(r'(\d{1,2})[\s\-/\.]*([a-zéûâôîïç\s]+)[\s\-/\.]*(\d{4})', date_clean)
    if match_literal:
        try:
            day_val = int(match_literal.group(1))
            month_str = match_literal.group(2).strip()
            year_val = int(match_literal.group(3))
            if month_str in months_fr:
                return f"{year_val:04d}-{months_fr[month_str]:02d}-{day_val:02d}"
        except ValueError:
            pass

    # Uniformiser les séparateurs (/ et . deviennent -)
    normalized: str = re.sub(r'[./]', '-', date_str.strip())

    # Format YYYY-MM-DD (déjà correct, juste normaliser le padding)
    match_ymd = re.match(r'^(\d{4})-(\d{1,2})-(\d{1,2})$', normalized)
    if match_ymd:
        try:
            year, month, day = map(int, match_ymd.groups())
            return f"{year:04d}-{month:02d}-{day:02d}"
        except ValueError:
            pass

    # Format DD-MM-YYYY ou DD-MM-YY
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


# =============================================================================
# Analyse du texte extrait par expressions régulières
# =============================================================================

def parse_invoice_text(text: str) -> Dict:
    """
    Parse le texte brut OCR pour en extraire les champs de facture.

    Utilise une batterie de regex calibrées pour les formats de factures
    tunisiennes et françaises. Chaque groupe de patterns est ordonné du
    plus spécifique au plus générique pour maximiser la précision.

    Le score de confiance est calculé proportionnellement au nombre de
    champs effectivement trouvés (sur 7 champs cibles).

    Args:
        text: Texte brut issu de Tesseract.

    Returns:
        Dictionnaire avec les champs extraits, le score de confiance,
        la source d'extraction et un extrait du texte brut.
    """
    result: Dict = {
        "fournisseur": None,
        "numero": None,
        "date_facture": None,
        "ht": None,
        "tva": None,
        "ttc": None,
        "iban": None,
        "devise": "TND",
        "items": None,
        "confiance": 0.0,
        "source": "ocr_tesseract",
        "texte_brut": text[:500] if text else "",
    }

    if not text:
        return result

    champs_trouves: float = 0
    total_champs: int = 7

    # ── Numéro de facture ──────────────────────────────────────────
    num_patterns: list[str] = [
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
    date_patterns: list[str] = [
        r'(?:date|le|du|émise?\s+le)\s*[:#]?\s*(\d{1,2}[/\-\.]\d{1,2}[/\-\.]\d{2,4})',
        r'\b(\d{1,2}[/\-\.]\d{1,2}[/\-\.]\d{4})\b',
        r'\b(\d{4}[/\-\.]\d{1,2}[/\-\.]\d{1,2})\b',
    ]
    for pattern in date_patterns:
        match = re.search(pattern, text, re.IGNORECASE)
        if match:
            result["date_facture"] = normalize_date(match.group(1).strip())
            champs_trouves += 1
            break

    # ── Montants financiers ────────────────────────────────────────
    def extract_amount(patterns: list[str], text_to_search: str) -> Optional[float]:
        """Extrait et nettoie un montant numérique depuis le texte brut."""
        for p in patterns:
            m = re.search(p, text_to_search, re.IGNORECASE)
            if m:
                amount_str: str = m.group(1).strip()
                cleaned: str = re.sub(r'[^\d.,]', '', amount_str)
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
                    if len(parts) == 2 and len(parts[1]) <= 3:
                        cleaned = cleaned.replace(',', '.')
                    else:
                        cleaned = cleaned.replace(',', '')
                try:
                    return float(cleaned)
                except ValueError:
                    continue
        return None

    # Montant HT (Hors Taxes)
    ht_patterns: list[str] = [
        r'(?:montant\s+)?(?:H\.?T\.?|hors\s+taxes?)\s*[:#]?\s*([\d\s,.]+)',
        r'(?:total|sous.?total)\s+(?:H\.?T\.?)\s*[:#]?\s*([\d\s,.]+)',
        r'(?:H\.?T\.?)\s*[:#]?\s*([\d\s,.]+)',
    ]
    result["ht"] = extract_amount(ht_patterns, text)
    if result["ht"]:
        champs_trouves += 1

    # Montant TVA
    tva_patterns: list[str] = [
        r'(?:T\.?V\.?A\.?|taxe)\s*(?:\(\d+%?\))?\s*[:#]?\s*([\d\s,.]+)',
        r'(?:montant\s+)?(?:T\.?V\.?A\.?)\s*[:#]?\s*([\d\s,.]+)',
    ]
    result["tva"] = extract_amount(tva_patterns, text)
    if result["tva"]:
        champs_trouves += 1

    # Montant TTC (Toutes Taxes Comprises)
    ttc_patterns: list[str] = [
        r'(?:montant\s+)?(?:T\.?T\.?C\.?|toutes\s+taxes)\s*[:#]?\s*([\d\s,.]+)',
        r'(?:total|net\s+[àa]\s+payer)\s*[:#]?\s*([\d\s,.]+)',
        r'(?:T\.?T\.?C\.?)\s*[:#]?\s*([\d\s,.]+)',
    ]
    result["ttc"] = extract_amount(ttc_patterns, text)
    if result["ttc"]:
        champs_trouves += 1

    # ── IBAN ───────────────────────────────────────────────────────
    iban_pattern: str = r'\b([A-Z]{2}\d{2}[\s]?[\dA-Z]{4,30})\b'
    iban_match = re.search(iban_pattern, text)
    if iban_match:
        iban_candidate: str = iban_match.group(1).replace(" ", "")
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

    # ── Fournisseur (détection par mots-clés puis première ligne) ──
    lines: list[str] = [l.strip() for l in text.split("\n") if l.strip() and len(l.strip()) > 3]
    known_suppliers: list[str] = ["STEG", "Orange", "Tunisie Telecom", "Amazon", "AWS", "SOPAT"]
    for supplier in known_suppliers:
        if supplier.lower() in text.lower():
            result["fournisseur"] = supplier
            champs_trouves += 1
            break

    if not result["fournisseur"] and lines:
        result["fournisseur"] = lines[0][:100]
        champs_trouves += 0.5  # Demi-point car peu fiable

    # ── Score de confiance ─────────────────────────────────────────
    result["confiance"] = round(min(champs_trouves / total_champs, 1.0), 2)

    return result


# =============================================================================
# Extraction intelligente via l'API Gemini
# =============================================================================

def extract_with_gemini(image_path: str) -> Optional[Dict]:
    """
    Extrait les données de facture via l'API Gemini (modèle multimodal).

    Utilise la Files API de Gemini pour téléverser le document entier
    (image ou PDF), puis demande une extraction structurée au format
    JSON conforme au schéma InvoiceData. Le prompt est calibré pour
    les factures tunisiennes (3 décimales pour les millimes, noms
    commerciaux locaux, format de date ISO).

    Le fichier est systématiquement supprimé de Gemini après
    traitement pour des raisons de confidentialité et de sécurité.

    Args:
        image_path: Chemin vers le document (image ou PDF).

    Returns:
        Dictionnaire avec les données extraites et source='gemini_api',
        ou None si l'extraction échoue.
    """
    if not GEMINI_API_KEY:
        print("[WARNING] GEMINI_API_KEY non configure. Saut de l'extraction Gemini.")
        return None

    try:
        from google import genai

        print("[INFO] Lancement de l'extraction intelligente avec Gemini API...")
        client = genai.Client(api_key=GEMINI_API_KEY)

        # Téléverser le document via la Files API (gère images ET PDFs)
        print(f"[INFO] Upload du document '{os.path.basename(image_path)}' vers Gemini Files API...")
        uploaded_file = client.files.upload(file=image_path)
        print(f"[INFO] Upload reussi. Nom distant : {uploaded_file.name}")

        prompt: str = (
            "Tu es un expert en comptabilite et extraction de donnees de factures.\n"
            "Extrais les informations de cette facture avec une precision absolue.\n"
            "\n"
            "Regles CRITIQUES :\n"
            "1. Lis CHAQUE champ directement depuis le document. Ne devine rien.\n"
            "2. Les montants tunisiens (TND/DT) ont 3 decimales (millimes). Garde la precision exacte.\n"
            "3. Le format de date DOIT etre AAAA-MM-JJ.\n"
            "4. Si un champ n'est pas present dans le document, mets null.\n"
            "5. Pour le fournisseur, utilise le nom commercial (STEG, Orange, Tunisie Telecom, etc.).\n"
            "6. Extrais les lignes de facturation individuelles si elles sont visibles.\n"
            "7. Identifie la devise (TND, EUR, USD) depuis le document."
        )

        try:
            response = client.models.generate_content(
                model="gemini-2.5-flash",
                contents=[uploaded_file, prompt],
                config={
                    "response_mime_type": "application/json",
                    "response_schema": InvoiceData,
                },
            )

            if response.parsed:
                data: Dict = response.parsed.model_dump()
                data["source"] = "gemini_api"
                data["confiance"] = 0.95
                data["texte_brut"] = f"[Gemini] Extraction reussie depuis : {os.path.basename(image_path)}"
                
                # Normalisation de la date retournee par l'IA
                if data.get("date_facture"):
                    data["date_facture"] = normalize_date(data["date_facture"])
                    
                print("[SUCCESS] Extraction Gemini reussie.")
                return data

        finally:
            # Toujours nettoyer le fichier distant, même en cas d'erreur
            try:
                print(f"[INFO] Nettoyage du fichier distant '{uploaded_file.name}'...")
                client.files.delete(name=uploaded_file.name)
            except Exception as clean_err:
                print(f"[WARNING] Impossible de supprimer le fichier temporaire Gemini : {clean_err}")

    except Exception as e:
        print(f"[ERROR] Echec de l'extraction Gemini : {e}")

    return None


# =============================================================================
# Point d'entrée principal — Orchestration de la stratégie 3 niveaux
# =============================================================================

def extract_invoice_data(image_path: str, filename: str = "") -> Dict:
    """
    Point d'entrée principal pour l'extraction de données de facture.

    Orchestre la stratégie d'extraction à 3 niveaux :
      1. Gemini API (si la clé est configurée) — extraction IA multimodale
      2. Tesseract + regex (si installé) — OCR local + parsing
      3. Fallback minimal — dictionnaire vide, sans données inventées

    Ajoute des métadonnées de traçabilité (source, confiance, disponibilité
    des outils) et effectue une validation croisée HT + TVA ~ TTC quand
    les trois montants sont disponibles.

    Args:
        image_path: Chemin vers le fichier uploadé (image ou PDF).
        filename: Nom original du fichier (pour la traçabilité).

    Returns:
        Dictionnaire structuré avec les données extraites, les métadonnées
        et le résultat de la validation.
    """
    result: Optional[Dict] = None

    # ── Niveau 1 : Gemini API (prioritaire) ────────────────────────
    if GEMINI_API_KEY:
        result = extract_with_gemini(image_path)

    # ── Niveau 2 : Tesseract OCR + parsing regex ──────────────────
    if result is None and TESSERACT_AVAILABLE:
        try:
            raw_text: str = extract_text_from_image(image_path)
            if raw_text and len(raw_text.strip()) > 20:
                result = parse_invoice_text(raw_text)
                print(f"[INFO] Extraction Tesseract terminee (confiance: {result.get('confiance', 0)}).")
        except Exception as e:
            print(f"[ERROR] Erreur lors de l'extraction OCR : {e}")

    # ── Niveau 3 : Fallback minimal (aucune donnée inventée) ──────
    if result is None:
        print("[WARNING] Aucune methode d'extraction n'a fonctionne. Retour fallback minimal.")
        result = {
            "fournisseur": None,
            "numero": None,
            "date_facture": None,
            "ht": None,
            "tva": None,
            "ttc": None,
            "iban": None,
            "devise": "TND",
            "items": None,
            "confiance": 0.1,
            "source": "fallback",
            "texte_brut": "",
        }

    # ── Métadonnées de traçabilité ─────────────────────────────────
    result["tesseract_disponible"] = TESSERACT_AVAILABLE
    result["gemini_utilise"] = (result.get("source") == "gemini_api")
    result["fichier_source"] = filename or os.path.basename(image_path)

    # ── Validation croisée HT + TVA ≈ TTC ─────────────────────────
    # Tolérance de 1.0 pour absorber les arrondis (surtout les 3 décimales
    # tunisiennes qui peuvent créer des écarts de quelques millimes).
    ht_val = result.get("ht")
    tva_val = result.get("tva")
    ttc_val = result.get("ttc")

    if ht_val is not None and tva_val is not None and ttc_val is not None:
        ecart: float = abs((ht_val + tva_val) - ttc_val)
        result["validation_montants"] = {
            "ht_plus_tva": round(ht_val + tva_val, 3),
            "ttc": ttc_val,
            "ecart": round(ecart, 3),
            "valide": ecart <= 1.0,
        }
    else:
        result["validation_montants"] = {
            "valide": None,
            "message": "Validation impossible : montants incomplets.",
        }

    return result
