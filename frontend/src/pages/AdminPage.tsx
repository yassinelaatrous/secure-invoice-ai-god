import { useState, useEffect } from 'react';
import api from '../api';
import { Activity, Settings } from 'lucide-react';

const AdminPage = () => {
  const [activeTab, setActiveTab] = useState('regles');
  const [regles, setRegles] = useState<any[]>([]);
  const [auditLogs, setAuditLogs] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchData = async () => {
    setLoading(true);
    try {
      if (activeTab === 'regles') {
        const res = await api.get('/regles');
        setRegles(res.data);
      } else {
        const res = await api.get('/audit');
        setAuditLogs(res.data);
      }
    } catch (err) {
      console.error("Erreur de chargement", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, [activeTab]);

  const toggleRegle = async (id: number, currentStatus: boolean) => {
    try {
      await api.put(`/regles/${id}`, { active: !currentStatus });
      fetchData();
    } catch (err) {
      console.error("Erreur toggle règle", err);
    }
  };

  return (
    <div className="admin-page">
      
      <div className="admin-tabs">
        <button 
          className={`tab-btn ${activeTab === 'regles' ? 'active' : ''}`}
          onClick={() => setActiveTab('regles')}
        >
          <Settings size={18} /> Règles de Conformité
        </button>
        <button 
          className={`tab-btn ${activeTab === 'audit' ? 'active' : ''}`}
          onClick={() => setActiveTab('audit')}
        >
          <Activity size={18} /> Journal d'Audit
        </button>
      </div>

      <div className="glass-card admin-content">
        {loading ? (
          <div className="loading">Chargement...</div>
        ) : activeTab === 'regles' ? (
          <div className="rules-section">
            <h2>Moteur de Conformité</h2>
            <p className="text-muted">Activez ou désactivez les contrôles automatiques appliqués lors de l'import de factures.</p>
            
            <div className="rules-list">
              {regles.map(r => (
                <div key={r.id} className="rule-item">
                  <div className="rule-info">
                    <h3>{r.nom} <span className="rule-code">{r.code}</span></h3>
                    <p>{r.description}</p>
                  </div>
                  <div className="rule-toggle">
                    <label className="switch">
                      <input 
                        type="checkbox" 
                        checked={r.active} 
                        onChange={() => toggleRegle(r.id, r.active)}
                      />
                      <span className="slider round"></span>
                    </label>
                    <span className={r.active ? 'text-success' : 'text-error'}>
                      {r.active ? 'Actif' : 'Inactif'}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          </div>
        ) : (
          <div className="audit-section">
            <h2>Journal d'Audit de Sécurité</h2>
            <div className="table-responsive">
              <table className="data-table">
                <thead>
                  <tr>
                    <th>Date</th>
                    <th>Acteur</th>
                    <th>Action</th>
                    <th>Cible</th>
                    <th>Détails</th>
                    <th>IP</th>
                  </tr>
                </thead>
                <tbody>
                  {auditLogs.map(log => (
                    <tr key={log.id}>
                      <td>{new Date(log.date).toLocaleString('fr-FR')}</td>
                      <td><span className="badge badge-default">{log.acteur}</span></td>
                      <td><strong>{log.action}</strong></td>
                      <td>{log.cible}</td>
                      <td className="text-sm">{log.details}</td>
                      <td className="text-sm text-muted">{log.ip_address}</td>
                    </tr>
                  ))}
                  {auditLogs.length === 0 && (
                    <tr>
                      <td colSpan={6} className="text-center">Aucun log d'audit disponible.</td>
                    </tr>
                  )}
                </tbody>
              </table>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default AdminPage;
