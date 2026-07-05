from datetime import datetime
from typing import Dict, Any, List

def detect_fraud(facture_data: Dict[str, Any], fournisseurs_db: List[Any], factures_existantes: List[Any]) -> Dict[str, Any]:
    """
    Détecte les signes de fraude potentielle dans une facture.
    Retourne un score de risque (0-100) et une justification.
    """
    score_fraude = 0
    alertes_fraude = []
    
    fournisseur = facture_data.get("fournisseur", "")
    iban = facture_data.get("iban", "")
    ttc = facture_data.get("ttc", 0.0)
    devise = facture_data.get("devise", "EUR")
    numero = facture_data.get("numero", "")
    date_facture = facture_data.get("date_facture", "")
    
    # --- 1. Vérification du fournisseur ---
    fournisseur_info = None
    for f in fournisseurs_db:
        if f.nom.lower() in fournisseur.lower() or fournisseur.lower() in f.nom.lower() or f.nom_complet.lower() in fournisseur.lower():
            fournisseur_info = f
            break
            
    if fournisseur_info:
        # Vérification IBAN
        official_iban = fournisseur_info.iban_officiel.replace(" ", "").upper()
        input_iban = str(iban).replace(" ", "").upper()
        
        if official_iban != input_iban and input_iban:
            score_fraude += 65
            alertes_fraude.append(
                f"Modification suspecte de coordonnées bancaires ! L'IBAN fourni ({iban}) "
                f"ne correspond pas à l'IBAN officiel enregistré pour {fournisseur_info.nom} ({fournisseur_info.iban_officiel})."
            )
            
        # Vérification Montant
        limite_atypique = fournisseur_info.montant_moyen_mensuel * 3
        if ttc and ttc > limite_atypique:
            score_fraude += 25
            alertes_fraude.append(
                f"Montant anormalement élevé : {ttc:.2f} {devise} (la moyenne habituelle pour "
                f"{fournisseur_info.nom} est de {fournisseur_info.montant_moyen_mensuel:.2f} {fournisseur_info.devise})."
            )
    else:
        # Fournisseur inconnu
        if fournisseur:
            score_fraude += 40
            alertes_fraude.append(
                f"Fournisseur '{fournisseur}' inconnu dans l'annuaire de confiance de l'entreprise."
            )

    # --- 2. Vérification des doublons ---
    for f in factures_existantes:
        if f.fournisseur and fournisseur and f.fournisseur.lower() == fournisseur.lower():
            if f.numero == numero and numero:
                score_fraude += 30
                alertes_fraude.append(
                    f"Doublon potentiel : Le numéro de facture '{numero}' existe déjà "
                    f"pour ce fournisseur (Enregistré sur la facture {f.id})."
                )
            elif f.ttc is not None and ttc is not None and abs(f.ttc - ttc) < 0.01 and f.date_facture and date_facture:
                try:
                    f_date = datetime.strptime(str(f.date_facture), "%Y-%m-%d").date()
                    curr_date = datetime.strptime(str(date_facture), "%Y-%m-%d").date()
                    if abs((f_date - curr_date).days) < 2:
                        score_fraude += 20
                        alertes_fraude.append(
                            f"Doublon potentiel : Une facture du même montant ({ttc:.2f} {devise}) "
                            f"a été émise pour ce fournisseur à une date similaire ({f.date_facture})."
                        )
                except ValueError:
                    pass

    # Limitation du score à 100 max
    score_fraude = min(score_fraude, 100)
    
    # Justification synthétique
    if score_fraude >= 70:
        justification = "Risque critique de fraude. Plusieurs anomalies graves détectées."
    elif score_fraude >= 35:
        justification = "Risque modéré. Des écarts ou un fournisseur inconnu nécessitent une vérification manuelle."
    else:
        justification = "Risque faible. Données cohérentes avec le référentiel de confiance."

    return {
        "score": score_fraude,
        "justification": justification,
        "alertes": alertes_fraude
    }
