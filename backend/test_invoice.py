import unittest
from datetime import datetime
from compliance import check_compliance
from fraud_detector import detect_fraud

class TestCompliance(unittest.TestCase):
    def setUp(self):
        self.rules = [
            {"code": "CHAMPS_OBLIGATOIRES", "active": True},
            {"code": "COHERENCE_TVA", "active": True},
            {"code": "VALIDITE_DATE", "active": True},
            {"code": "IBAN_VALIDE", "active": True}
        ]

    def test_compliance_valid_invoice(self):
        invoice = {
            "fournisseur": "Amazon Business FR",
            "numero": "INV-2026-991",
            "date_facture": "2026-07-10",
            "ht": 100.0,
            "tva": 20.0,
            "ttc": 120.0,
            "iban": "FR7630006000011234567890188"
        }
        res = check_compliance(invoice, self.rules)
        self.assertTrue(res["valide"])
        self.assertEqual(len(res["details"]), 0)

    def test_compliance_missing_fields(self):
        invoice = {
            "fournisseur": "",
            "numero": "",
            "date_facture": "",
            "ht": 100.0,
            "tva": 20.0,
            "ttc": -10.0
        }
        res = check_compliance(invoice, self.rules)
        self.assertFalse(res["valide"])
        self.assertTrue(any("fournisseur" in err for err in res["details"]))
        self.assertTrue(any("Numéro" in err for err in res["details"]))

    def test_compliance_tva_mismatch(self):
        invoice = {
            "fournisseur": "Amazon Business FR",
            "numero": "INV-2026-991",
            "date_facture": "2026-07-10",
            "ht": 100.0,
            "tva": 20.0,
            "ttc": 150.0 # Error: 100 + 20 != 150
        }
        res = check_compliance(invoice, self.rules)
        self.assertFalse(res["valide"])
        self.assertTrue(any("Calcul incorrect" in err for err in res["details"]))

class MockFournisseur:
    def __init__(self, nom, nom_complet, iban_officiel, montant_moyen_mensuel, devise="EUR"):
        self.nom = nom
        self.nom_complet = nom_complet
        self.iban_officiel = iban_officiel
        self.montant_moyen_mensuel = montant_moyen_mensuel
        self.devise = devise

class MockFacture:
    def __init__(self, id, fournisseur, numero, ttc, date_facture):
        self.id = id
        self.fournisseur = fournisseur
        self.numero = numero
        self.ttc = ttc
        self.date_facture = date_facture

class TestFraudDetector(unittest.TestCase):
    def setUp(self):
        self.fournisseurs = [
            MockFournisseur("STEG", "Société Tunisienne de l'Électricité et du Gaz", "TN5900100200300400500607", 500.0, "TND"),
            MockFournisseur("Amazon", "Amazon Business FR", "FR7630006000011234567890188", 1000.0, "EUR")
        ]
        self.factures = [
            MockFacture(1, "Amazon", "INV-2026-001", 120.0, "2026-07-01")
        ]

    def test_fraud_steg_invalid_iban(self):
        invoice = {
            "fournisseur": "STEG",
            "numero": "INV-2026-080",
            "date_facture": "2026-07-12",
            "ttc": 200.0,
            "iban": "TN599999999999999999999999" # Fake
        }
        res = detect_fraud(invoice, self.fournisseurs, self.factures)
        self.assertGreaterEqual(res["score"], 65)
        self.assertTrue(any("Modification suspecte" in al for al in res["alertes"]))

    def test_fraud_duplicate_invoice(self):
        invoice = {
            "fournisseur": "Amazon",
            "numero": "INV-2026-001", # Duplicate number
            "date_facture": "2026-07-01",
            "ttc": 120.0,
            "iban": "FR7630006000011234567890188"
        }
        res = detect_fraud(invoice, self.fournisseurs, self.factures)
        self.assertGreaterEqual(res["score"], 30)
        self.assertTrue(any("Doublon potentiel" in al for al in res["alertes"]))

if __name__ == "__main__":
    unittest.main()
