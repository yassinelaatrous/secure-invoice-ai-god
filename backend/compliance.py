from datetime import datetime
from typing import Dict, Any, List

def check_compliance(facture_data: Dict[str, Any], rules: List[Dict[str, Any]]) -> Dict[str, Any]:
    """
    Vérifie la conformité d'une facture par rapport aux règles configurées.
    """
    erreurs = []
    
    ht = facture_data.get("ht", 0.0)
    tva = facture_data.get("tva", 0.0)
    ttc = facture_data.get("ttc", 0.0)
    fournisseur = facture_data.get("fournisseur", "")
    numero = facture_data.get("numero", "")
    date_facture = facture_data.get("date_facture", "")
    iban = facture_data.get("iban", "")
    devise = facture_data.get("devise", "EUR")

    # Règle 1 : CHAMPS_OBLIGATOIRES
    regle_champs = next((r for r in rules if r["code"] == "CHAMPS_OBLIGATOIRES"), None)
    if regle_champs and regle_champs.get("active"):
        if not fournisseur or not str(fournisseur).strip():
            erreurs.append("Nom du fournisseur manquant.")
        if not numero or not str(numero).strip():
            erreurs.append("Numéro de facture manquant.")
        if not date_facture or not str(date_facture).strip():
            erreurs.append("Date de facture manquante.")
        if ttc is None or ttc <= 0:
            erreurs.append("Le montant total TTC doit être supérieur à zéro.")

    # Règle 2 : COHERENCE_TVA
    regle_tva = next((r for r in rules if r["code"] == "COHERENCE_TVA"), None)
    if regle_tva and regle_tva.get("active") and ht > 0:
        calcul_attendu = round(ht + tva, 2)
        difference = abs(calcul_attendu - round(ttc, 2))
        if difference > 0.05:
            erreurs.append(
                f"Calcul incorrect : HT ({ht:.2f}) + TVA ({tva:.2f}) = {calcul_attendu:.2f} {devise}, "
                f"mais le TTC indiqué est {ttc:.2f} {devise} (écart de {difference:.2f} {devise})."
            )

    # Règle 3 : VALIDITE_DATE
    regle_date = next((r for r in rules if r["code"] == "VALIDITE_DATE"), None)
    if regle_date and regle_date.get("active") and date_facture:
        try:
            date_obj = datetime.strptime(str(date_facture), "%Y-%m-%d").date()
            if date_obj > datetime.now().date():
                erreurs.append(f"La date de la facture ({date_facture}) est dans le futur.")
        except ValueError:
            erreurs.append("Le format de la date est incorrect (attendu: AAAA-MM-JJ).")

    # Règle 4 : IBAN_VALIDE
    regle_iban = next((r for r in rules if r["code"] == "IBAN_VALIDE"), None)
    if regle_iban and regle_iban.get("active") and iban:
        clean_iban = str(iban).replace(" ", "").upper()
        if len(clean_iban) < 15:
            erreurs.append(f"L'IBAN indiqué ({iban}) est trop court ou mal formaté.")

    return {
        "valide": len(erreurs) == 0,
        "details": erreurs
    }
