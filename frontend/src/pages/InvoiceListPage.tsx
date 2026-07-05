import React, { useState, useEffect, useContext } from 'react';
import api from '../api';
import { AuthContext } from '../context/AuthContext';
import { Search, Filter, Eye, CheckCircle, XCircle, AlertTriangle } from 'lucide-react';

const InvoiceListPage = () => {
  const [factures, setFactures] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedFacture, setSelectedFacture] = useState<any>(null);
  const { user } = useContext(AuthContext);

  const fetchFactures = async () => {
    try {
      const res = await api.get('/factures');
      setFactures(res.data);
    } catch (err) {
      console.error("Erreur chargement factures", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchFactures();
  }, []);

  const handleStatusChange = async (id: number, newStatus: string) => {
    try {
      await api.put(`/factures/${id}/statut`, { statut: newStatus });
      setSelectedFacture({ ...selectedFacture, statut: newStatus });
      fetchFactures(); // Refresh list
    } catch (err) {
      console.error("Erreur mise à jour statut", err);
      alert("Erreur lors de la mise à jour du statut");
    }
  };

  if (loading) return <div className="loading">Chargement des factures...</div>;

  return (
    <div className="invoice-list-page">
      <div className="page-header">
        <div className="search-bar">
          <Search size={18} className="search-icon" />
          <input type="text" placeholder="Rechercher une facture (Fournisseur, Numéro...)" />
        </div>
        <button className="btn btn-outline"><Filter size={18} /> Filtrer</button>
      </div>

      <div className="glass-card table-container">
        <table className="data-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Fournisseur</th>
              <th>Date</th>
              <th>Montant TTC</th>
              <th>Conformité</th>
              <th>Score Risque</th>
              <th>Statut</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {factures.map(f => (
              <tr key={f.id} onClick={() => setSelectedFacture(f)}>
                <td>#{f.id}</td>
                <td>{f.fournisseur}</td>
                <td>{f.date_facture}</td>
                <td>{f.ttc ? `${f.ttc.toFixed(2)} ${f.devise}` : '-'}</td>
                <td>
                  {f.conformite_valide ? 
                    <span className="text-success flex-center"><CheckCircle size={16}/> Valide</span> : 
                    <span className="text-error flex-center"><XCircle size={16}/> Non conforme</span>
                  }
                </td>
                <td>
                  <span className={`risk-badge ${f.fraude_score > 70 ? 'high' : f.fraude_score > 30 ? 'medium' : 'low'}`}>
                    {f.fraude_score}%
                  </span>
                </td>
                <td><span className={`badge badge-${f.statut}`}>{f.statut}</span></td>
                <td>
                  <button className="btn btn-icon" onClick={(e) => { e.stopPropagation(); setSelectedFacture(f); }}>
                    <Eye size={18} />
                  </button>
                </td>
              </tr>
            ))}
            {factures.length === 0 && (
              <tr>
                <td colSpan={8} className="text-center py-4">Aucune facture trouvée.</td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {/* Modal Détails Facture */}
      {selectedFacture && (
        <div className="modal-overlay" onClick={() => setSelectedFacture(null)}>
          <div className="modal-content glass-card" onClick={e => e.stopPropagation()}>
            <div className="modal-header">
              <h2>Facture #{selectedFacture.numero} - {selectedFacture.fournisseur}</h2>
              <button className="btn-close" onClick={() => setSelectedFacture(null)}>×</button>
            </div>
            
            <div className="modal-body">
              <div className="details-grid">
                
                {/* Infos Générales */}
                <div className="detail-panel">
                  <h3>Informations Générales</h3>
                  <div className="info-row"><span className="label">Date:</span> <span>{selectedFacture.date_facture}</span></div>
                  <div className="info-row"><span className="label">Montant HT:</span> <span>{selectedFacture.ht} {selectedFacture.devise}</span></div>
                  <div className="info-row"><span className="label">TVA:</span> <span>{selectedFacture.tva} {selectedFacture.devise}</span></div>
                  <div className="info-row"><span className="label">Montant TTC:</span> <span className="highlight">{selectedFacture.ttc} {selectedFacture.devise}</span></div>
                  <div className="info-row"><span className="label">IBAN:</span> <span>{selectedFacture.iban || 'Non renseigné'}</span></div>
                  <div className="info-row"><span className="label">Statut:</span> <span className={`badge badge-${selectedFacture.statut}`}>{selectedFacture.statut}</span></div>
                </div>

                {/* Conformité */}
                <div className="detail-panel">
                  <h3>Analyse de Conformité</h3>
                  {selectedFacture.conformite_valide ? (
                    <div className="alert success"><CheckCircle size={18}/> Tous les contrôles sont au vert.</div>
                  ) : (
                    <div className="alert error">
                      <XCircle size={18}/> Non-conformités détectées:
                      <ul>
                        {JSON.parse(selectedFacture.conformite_details || '[]').map((err: string, i: number) => (
                          <li key={i}>{err}</li>
                        ))}
                      </ul>
                    </div>
                  )}
                </div>

                {/* Fraude */}
                <div className="detail-panel full-width">
                  <h3>Détection de Fraude IA</h3>
                  <div className="fraud-container">
                    <div className="fraud-gauge" style={{ '--value': selectedFacture.fraude_score } as React.CSSProperties}>
                      <span className="fraud-score-text">{selectedFacture.fraude_score}%</span>
                    </div>
                    <div className="fraud-details">
                      <p><strong>{selectedFacture.fraude_justification}</strong></p>
                      {JSON.parse(selectedFacture.fraude_alertes || '[]').length > 0 && (
                        <ul className="fraud-alerts">
                          {JSON.parse(selectedFacture.fraude_alertes).map((alerte: string, i: number) => (
                            <li key={i} className="text-error"><AlertTriangle size={14}/> {alerte}</li>
                          ))}
                        </ul>
                      )}
                    </div>
                  </div>
                </div>

              </div>
            </div>

            {/* Actions (réservées aux comptables/admins) */}
            {(user?.role === 'comptable' || user?.role === 'admin') && selectedFacture.statut !== 'validee' && selectedFacture.statut !== 'rejetee' && (
              <div className="modal-footer">
                <button className="btn btn-error" onClick={() => handleStatusChange(selectedFacture.id, 'rejetee')}>
                  Rejeter la facture
                </button>
                <button className="btn btn-success" onClick={() => handleStatusChange(selectedFacture.id, 'validee')}>
                  Valider pour paiement
                </button>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
};

export default InvoiceListPage;
