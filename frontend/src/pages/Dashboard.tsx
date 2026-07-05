import { useState, useEffect } from 'react';
import api from '../api';
import { FileText, DollarSign, AlertTriangle, ShieldAlert } from 'lucide-react';
import { Link } from 'react-router-dom';

const Dashboard = () => {
  const [factures, setFactures] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
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
    fetchFactures();
  }, []);

  const stats = {
    total: factures.length,
    montant: factures.reduce((sum, f) => sum + (f.ttc || 0), 0),
    risqueMoyen: factures.length ? factures.reduce((sum, f) => sum + (f.fraude_score || 0), 0) / factures.length : 0,
    alertes: factures.filter(f => f.fraude_score > 30).length
  };

  if (loading) return <div className="loading">Chargement du tableau de bord...</div>;

  return (
    <div className="dashboard">
      <div className="kpi-grid">
        <div className="kpi-card glass-card">
          <div className="kpi-icon"><FileText size={24} color="#6366f1" /></div>
          <div className="kpi-data">
            <h3>Total Factures</h3>
            <div className="kpi-value">{stats.total}</div>
          </div>
        </div>
        <div className="kpi-card glass-card">
          <div className="kpi-icon"><DollarSign size={24} color="#10b981" /></div>
          <div className="kpi-data">
            <h3>Montant Total</h3>
            <div className="kpi-value">{stats.montant.toLocaleString('fr-FR', { style: 'currency', currency: 'EUR' })}</div>
          </div>
        </div>
        <div className="kpi-card glass-card">
          <div className="kpi-icon"><ShieldAlert size={24} color="#f59e0b" /></div>
          <div className="kpi-data">
            <h3>Risque Moyen</h3>
            <div className="kpi-value">{Math.round(stats.risqueMoyen)}%</div>
          </div>
        </div>
        <div className="kpi-card glass-card">
          <div className="kpi-icon"><AlertTriangle size={24} color="#ef4444" /></div>
          <div className="kpi-data">
            <h3>Alertes Fraude</h3>
            <div className="kpi-value">{stats.alertes}</div>
          </div>
        </div>
      </div>

      <div className="dashboard-section glass-card">
        <div className="section-header">
          <h2>Factures Récentes</h2>
          <Link to="/factures" className="btn btn-outline">Voir tout</Link>
        </div>
        
        {factures.length === 0 ? (
          <div className="empty-state">Aucune facture pour le moment.</div>
        ) : (
          <div className="table-responsive">
            <table className="data-table">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Fournisseur</th>
                  <th>Date</th>
                  <th>Montant</th>
                  <th>Statut</th>
                </tr>
              </thead>
              <tbody>
                {factures.slice(0, 5).map(f => (
                  <tr key={f.id}>
                    <td>#{f.id}</td>
                    <td>{f.fournisseur || 'Inconnu'}</td>
                    <td>{f.date_facture}</td>
                    <td>{f.ttc ? `${f.ttc.toFixed(2)} ${f.devise}` : '-'}</td>
                    <td><span className={`badge badge-${f.statut}`}>{f.statut}</span></td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
};

export default Dashboard;
