import React, { useState, useContext } from 'react';
import { useLocation } from 'react-router-dom';
import { AuthContext } from '../context/AuthContext';
import CapturePage from './CapturePage';
import InvoiceListPage from './InvoiceListPage';
import AdminPage from './AdminPage';
import { Line } from 'react-chartjs-2';
import { 
  Chart as ChartJS, CategoryScale, LinearScale, PointElement, 
  LineElement, Title, Tooltip, Legend, ArcElement, Filler
} from 'chart.js';
import { 
  FileText, ShieldAlert, TrendingUp, FileCheck, 
  Zap, ArrowRight, Settings
} from 'lucide-react';

ChartJS.register(CategoryScale, LinearScale, PointElement, LineElement, Title, Tooltip, Legend, ArcElement, Filler);

// Fictional mockup data
const mockupFactures = [
  { num: "2026-F-0134", client: "Office Matériel", date: "15/05/2026", montant: 2450, statut: "Impayée" },
  { num: "2026-F-0133", client: "Global Printing", date: "14/05/2026", montant: 980, statut: "En retard" },
  { num: "2026-F-0132", client: "Le Bon Goût Traiteur", date: "12/05/2026", montant: 1350, statut: "En retard" },
  { num: "2026-F-0131", client: "Digital Solutions", date: "10/05/2026", montant: 3820, statut: "Payée" },
  { num: "2026-F-0130", client: "Alpha Industrie", date: "08/05/2026", montant: 7200, statut: "Partiellement payée" }
];

const chartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: { legend: { display: false }, tooltip: { mode: 'index' as const, intersect: false } },
  scales: { 
    x: { grid: { display: false }, border: { display: false } }, 
    y: { grid: { color: 'rgba(255,255,255,0.05)' }, border: { display: false } } 
  },
  interaction: { mode: 'nearest' as const, axis: 'x' as const, intersect: false }
};

const chartData = {
  labels: ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'],
  datasets: [{
    label: 'Temps de traitement (h)',
    data: [4.2, 3.8, 5.1, 2.9, 4.5, 1.2, 0],
    borderColor: '#bbfb95',
    backgroundColor: 'rgba(187, 251, 149, 0.1)',
    borderWidth: 3,
    tension: 0.4,
    fill: true,
    pointBackgroundColor: '#1c1a19',
    pointBorderColor: '#bbfb95',
    pointBorderWidth: 2,
    pointRadius: 4,
    pointHoverRadius: 6
  }]
};

const Dashboard = () => {
  const { demoRole } = useContext(AuthContext);
  const location = useLocation();
  const [sliderValue, setSliderValue] = useState(85);

  const getActiveTab = () => {
    const path = location.pathname.substring(1);
    if (path === 'capture') return 'documents';
    if (path === 'admin') return 'securite';
    return path || 'dashboard';
  };
  const activeTab = getActiveTab();

  if (activeTab === 'documents') return <CapturePage />;
  if (activeTab === 'factures') return <InvoiceListPage />;
  if (activeTab === 'securite') return <AdminPage />;

  return (
    <div className="dashboard-content" style={{ paddingBottom: '3rem' }}>
      <div className="mytasky-grid">
        
        {/* Welcome Section */}
        <div className="mytasky-header-row">
          <div className="mytasky-welcome">
            <h1>Welcome, {demoRole === 'client' ? 'Ahmed' : demoRole === 'comptable' ? 'Sarah' : 'Karim'}!</h1>
            <p>Here is your financial overview & AI insights.</p>
          </div>
          
          <div className="quick-pills">
            <div className="quick-pill">
              <div className="qp-icon"><Zap size={20} /></div>
              <div className="qp-text">
                <h4>Invoice Bot</h4>
                <p>94% Automated</p>
              </div>
            </div>
            <div className="quick-pill">
              <div className="qp-icon" style={{ background: 'var(--secondary)' }}><TrendingUp size={20} color="#fff" /></div>
              <div className="qp-text">
                <h4>Data Analyzer</h4>
                <p>Optimization active</p>
              </div>
            </div>
            <div className="quick-pill">
              <div className="qp-icon" style={{ background: 'var(--primary)' }}><FileText size={20} color="#000" /></div>
              <div className="qp-text">
                <h4>Report AI</h4>
                <p>Generate now</p>
              </div>
            </div>
          </div>
        </div>

        {/* Task Time Chart Widget */}
        <div className="card-dark" style={{ display: 'flex', flexDirection: 'column' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '1.5rem', alignItems: 'flex-start' }}>
            <div>
              <h3 style={{ fontSize: '1.25rem', marginBottom: '4px' }}>Processing Time</h3>
              <p className="text-secondary" style={{ fontSize: '0.9rem' }}>Hours spent per day</p>
            </div>
            <button className="btn-icon"><Settings size={18} /></button>
          </div>
          <div style={{ flex: 1, minHeight: '220px', position: 'relative' }}>
            <Line data={chartData} options={chartOptions as any} />
          </div>
        </div>

        {/* High Contrast Tasks List Widget */}
        <div className="card-light">
          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '1.5rem', alignItems: 'center' }}>
            <h3 style={{ fontSize: '1.25rem', fontWeight: 700 }}>Recent Activity</h3>
            <span style={{ fontSize: '0.8rem', fontWeight: 600, color: '#6e6a68', background: 'rgba(0,0,0,0.05)', padding: '4px 10px', borderRadius: '12px' }}>View all</span>
          </div>
          <div className="table-responsive">
            <table className="data-table">
              <tbody>
                {mockupFactures.slice(0, 4).map((f, i) => (
                  <tr key={i}>
                    <td style={{ width: '40px' }}>
                      <div style={{ width: '36px', height: '36px', borderRadius: '10px', background: 'rgba(0,0,0,0.04)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                        <FileCheck size={18} color="#171413" />
                      </div>
                    </td>
                    <td>
                      <div className="cell-strong">{f.client}</div>
                      <div className="cell-mono text-secondary" style={{ marginTop: '2px' }}>{f.num}</div>
                    </td>
                    <td style={{ textAlign: 'right' }}>
                      <div className="cell-strong">{f.montant} TND</div>
                      <div style={{ fontSize: '0.75rem', marginTop: '2px', color: f.statut === 'Payée' ? '#10b981' : f.statut === 'Impayée' ? '#ef4444' : '#f59e0b', fontWeight: 600 }}>{f.statut}</div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {/* Optimize Workflow Widget */}
        <div className="card-gradient-green" style={{ display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
          <div>
            <h3 style={{ fontSize: '1.5rem', fontWeight: 800, marginBottom: '8px', lineHeight: 1.2 }}>Optimize<br/>Workflow</h3>
            <p style={{ fontSize: '0.9rem', color: 'rgba(0,0,0,0.6)', fontWeight: 500 }}>AI is ready to automate 4 pending tasks.</p>
          </div>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end', marginTop: '2rem' }}>
            <button style={{ background: '#171413', color: '#fff', border: 'none', padding: '12px 20px', borderRadius: '30px', display: 'flex', alignItems: 'center', gap: '8px', fontWeight: 600, cursor: 'pointer' }}>
              Enable Now <ArrowRight size={16} />
            </button>
            <div style={{ width: '64px', height: '64px', background: 'rgba(0,0,0,0.1)', borderRadius: '50%', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Zap size={32} color="#171413" />
            </div>
          </div>
        </div>

        {/* AI Confidence / Fraud Tolerance Slider (using the crazy CSS) */}
        <div className="card-dark" style={{ gridColumn: 'span 1' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '1rem', alignItems: 'center' }}>
            <h3 style={{ fontSize: '1.25rem', display: 'flex', alignItems: 'center', gap: '8px' }}>
              <ShieldAlert size={20} color="var(--primary)" /> 
              AI Autonomy Level
            </h3>
          </div>
          <p className="text-secondary" style={{ fontSize: '0.9rem', marginBottom: '2rem' }}>Adjust the confidence threshold required for automatic validation without human review.</p>
          
          <div className="ai-slider-wrapper">
            <label>
              <input 
                id="ai-autonomy" 
                type="range" 
                min="0" max="100" 
                value={sliderValue} 
                onChange={(e) => setSliderValue(parseInt(e.target.value))}
              />
              <output htmlFor="ai-autonomy" style={{ '--min': 0, '--max': 100 } as React.CSSProperties}><span></span></output>
            </label>
          </div>
          
          <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: '1rem', fontSize: '0.8rem', color: 'var(--text-secondary)' }}>
            <span>0% (Manual)</span>
            <span>100% (Full Auto)</span>
          </div>
        </div>

      </div>
    </div>
  );
};

export default Dashboard;
