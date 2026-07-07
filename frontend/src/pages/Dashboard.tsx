import { useState, useEffect, useContext } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import { AuthContext } from '../context/AuthContext';
import api from '../api';
import CapturePage from './CapturePage';
import InvoiceListPage from './InvoiceListPage';
import AdminPage from './AdminPage';
import { Line, Doughnut } from 'react-chartjs-2';
import { 
  Chart as ChartJS, 
  CategoryScale, 
  LinearScale, 
  PointElement, 
  LineElement, 
  Title, 
  Tooltip, 
  Legend, 
  ArcElement 
} from 'chart.js';
import { 
  Folder, 
  FileText, 
  Clock, 
  MessageSquare, 
  Calendar, 
  ShieldAlert, 
  DollarSign, 
  TrendingUp, 
  Plus, 
  Send,
  BookOpen,
  CheckCircle,
  AlertTriangle,
  FileCheck
} from 'lucide-react';

// Register Chart.js components
ChartJS.register(
  CategoryScale, 
  LinearScale, 
  PointElement, 
  LineElement, 
  Title, 
  Tooltip, 
  Legend, 
  ArcElement
);

// Fictional mockup data conforming to the CEO-IT specs
const mockupClients = [
  { name: "Société Tunisienne de Bâtiment", sigle: "STB", secteur: "BTP", statut: "Actif", solde: 2450 },
  { name: "Alpha Distribution", sigle: "ADI", secteur: "Négoce", statut: "Actif", solde: 0 },
  { name: "Le Bon Goût Traiteur", sigle: "LBG", secteur: "Restauration", statut: "En retard", solde: 1350 },
  { name: "MedixPlus", sigle: "MDX", secteur: "Santé", statut: "En onboarding", solde: 0 },
  { name: "Digital Solutions", sigle: "DGS", secteur: "IT", statut: "Actif", solde: 3820 },
  { name: "Office Matériel", sigle: "OFM", secteur: "Fournitures", statut: "Actif", solde: 2450 },
  { name: "Global Printing", sigle: "GPR", secteur: "Imprimerie", statut: "Suspendu", solde: 980 },
  { name: "Alpha Industrie", sigle: "AIN", secteur: "Industrie", statut: "Actif", solde: 7200 },
  { name: "Best Trade", sigle: "BTR", secteur: "Négoce", statut: "En retard", solde: 3600 },
  { name: "Next Consulting", sigle: "NXC", secteur: "Conseil", statut: "Actif", solde: 0 },
  { name: "Société Générale SARL", sigle: "SGS", secteur: "Services", statut: "Actif", solde: 4800 },
];

const mockupCollaborateurs = [
  { name: "Sarah Jlassi", role: "Comptable senior", charge: 85, dossiers: 14, couleur: "#3b7ddb" },
  { name: "Mehdi Ktari", role: "Comptable", charge: 70, dossiers: 11, couleur: "#f4841f" },
  { name: "Amira Bouaziz", role: "Responsable fiscal", charge: 60, dossiers: 9, couleur: "#1e9e6b" },
  { name: "Yassine Zaoui", role: "Assistant comptable", charge: 40, dossiers: 7, couleur: "#e14b4b" },
  { name: "Nadia Ben Youssef", role: "Comptable", charge: 64, dossiers: 10, couleur: "#8f6fe0" },
  { name: "Imen Trabelsi", role: "Gestionnaire de paie", charge: 52, dossiers: 8, couleur: "#f0b429" },
];

const mockupDocuments = [
  { nom: "Facture Orange Tunisie — Nov 2020", client: "Société Générale SARL", type: "Facture", periode: "11/2020", statut: "Validé", date: "01/11/2020" },
  { nom: "Facture STEG Tunisie", client: "Société Générale SARL", type: "Facture", periode: "06/2023", statut: "Validé", date: "12/06/2023" },
  { nom: "Relevé bancaire — BIAT", client: "Alpha Distribution", type: "Banque", periode: "05/2026", statut: "Nouveau", date: "29/05/2026" },
  { nom: "Contrat de prestation", client: "Le Bon Goût Traiteur", type: "Contrat", periode: "—", statut: "Validé", date: "28/05/2026" },
  { nom: "Déclaration TVA — Avril 2026", client: "Digital Solutions", type: "Déclaration", periode: "04/2026", statut: "Archivé", date: "20/05/2026" },
  { nom: "Bulletin de paie — Y. Sassi", client: "Alpha Industrie", type: "Paie", periode: "05/2026", statut: "Validé", date: "27/05/2026" },
  { nom: "Justificatif de paiement", client: "Best Trade", type: "Paiement", periode: "05/2026", statut: "À vérifier", date: "26/05/2026" },
  { nom: "Facture fournisseur — Global Printing", client: "Global Printing", type: "Facture", periode: "05/2026", statut: "Nouveau", date: "26/05/2026" },
];

const mockupFactures = [
  { num: "2026-F-0134", client: "Office Matériel", date: "15/05/2026", montant: 2450, statut: "Impayée" },
  { num: "2026-F-0133", client: "Global Printing", date: "14/05/2026", montant: 980, statut: "En retard" },
  { num: "2026-F-0132", client: "Le Bon Goût Traiteur", date: "12/05/2026", montant: 1350, statut: "En retard" },
  { num: "2026-F-0131", client: "Digital Solutions", date: "10/05/2026", montant: 3820, statut: "Payée" },
  { num: "2026-F-0130", client: "Alpha Industrie", date: "08/05/2026", montant: 7200, statut: "Partiellement payée" },
  { num: "2026-F-0129", client: "Best Trade", date: "05/05/2026", montant: 3600, statut: "En retard" },
  { num: "2026-F-0128", client: "Société Générale SARL", date: "02/05/2026", montant: 4800, statut: "Payée" },
];

const mockupEcheances = [
  { label: "Déclaration TVA", client: "Toutes entités", date: "12/06/2026", montant: 6400, statut: "À venir" },
  { label: "Paiement fournisseur — Office Matériel", client: "Office Matériel", date: "04/06/2026", montant: 2450, statut: "Urgent" },
  { label: "CNSS — Mai 2026", client: "Alpha Industrie", date: "15/06/2026", montant: 3200, statut: "À venir" },
  { label: "Règlement crédit — BIAT", client: "Le Bon Goût Traiteur", date: "20/06/2026", montant: 1150, statut: "À venir" },
];

const mockupAlertesFraude = [
  { type: "Doublon", detail: "2 factures identiques — Office Matériel, réf. OFM-2034", niveau: "Élevé" },
  { type: "IBAN modifié", detail: "Coordonnées bancaires changées — Global Printing", niveau: "Élevé" },
  { type: "Montant atypique", detail: "Écart de +340% vs historique — Best Trade", niveau: "Moyen" },
  { type: "Connexion suspecte", detail: "Nouvel appareil détecté — compte M. Ktari", niveau: "Faible" },
];

const Dashboard = () => {
  const { demoRole } = useContext(AuthContext);
  const location = useLocation();
  const navigate = useNavigate();

  const [facturesReal, setFacturesReal] = useState<any[]>([]);
  const [auditLogs, setAuditLogs] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  // Chat message state for Client tab
  const [chatMessages, setChatMessages] = useState([
    { text: "Bonjour, nous avons bien reçu votre relevé bancaire de mai. Merci !", isOut: false, time: "10:02" },
    { text: "Parfait, merci de me confirmer une fois le rapprochement effectué.", isOut: true, time: "10:05" },
    { text: "C'est noté. Il manque encore le RIB actualisé pour finaliser le dossier.", isOut: false, time: "10:11" },
    { text: "Je le dépose dans la journée depuis l'espace documents.", isOut: true, time: "10:12" },
    { text: "Nous avons ajouté de nouveaux documents à votre dossier.", isOut: false, time: "il y a 2h" },
  ]);
  const [chatInput, setChatInput] = useState('');

  // Collaborateur task manager state
  const [tasks, setTasks] = useState({
    todo: ["Vérifier relevé bancaire — STB", "Lettrage comptes clients", "Préparer clôture mensuelle — DGS"],
    progress: ["Saisir OD de valeur — Le Bon Goût", "Contrôle TVA — Mai 2026"],
    done: ["Rapprochement bancaire — ALPHA", "Facture — Société Générale SARL", "Déclaration TVA — Digital Solutions"]
  });

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [facturesRes, auditRes] = await Promise.all([
          api.get('/factures'),
          api.get('/audit').catch(() => ({ data: [] })) // Non-admins can't read audit
        ]);
        setFacturesReal(facturesRes.data);
        setAuditLogs(auditRes.data);
      } catch (err) {
        console.error("Error loading backend data", err);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  // Avoid unused variable warnings
  useEffect(() => {
    if (auditLogs.length > 0 || !loading) {
      console.log("[INFO] Dashboard active with", facturesReal.length, "invoices.");
    }
  }, [auditLogs, loading, facturesReal]);

  const getActiveTab = () => {
    const path = location.pathname.substring(1);
    if (path === 'capture') return 'documents';
    if (path === 'admin') return 'securite';
    return path || 'dashboard';
  };

  const activeTab = getActiveTab();

  const getStatusBadge = (status: string) => {
    const map: Record<string, string> = {
      "Actif": "b-green", "En retard": "b-red", "En onboarding": "b-gold", "Suspendu": "b-grey",
      "Nouveau": "b-blue", "À vérifier": "b-gold", "Validé": "b-green", "Refusé": "b-red", "Archivé": "b-grey",
      "Payée": "b-green", "Impayée": "b-red", "Partiellement payée": "b-gold", "Annulée": "b-grey",
      "À venir": "b-blue", "Urgent": "b-red", "Élevé": "b-red", "Moyen": "b-gold", "Faible": "b-grey"
    };
    return <span className={`badge ${map[status] || 'b-grey'}`}><span className="dot"></span>{status}</span>;
  };

  const money = (n: number) => {
    return n.toLocaleString('fr-FR') + " TND";
  };

  const getInitials = (name: string) => {
    return name.split(' ').filter(Boolean).slice(0, 2).map(w => w[0]).join('').toUpperCase();
  };

  const initialsColor = (str: string) => {
    const colors = ["#3b7ddb", "#f4841f", "#1e9e6b", "#8f6fe0", "#e14b4b", "#f0b429", "#3d2170"];
    let h = 0; 
    for (let i = 0; i < str.length; i++) h += str.charCodeAt(i);
    return colors[h % colors.length];
  };

  // SVGs for dynamic widgets
  const renderDonut = (percent: number, color: string) => {
    const r = 32;
    const c = 2 * Math.PI * r;
    const off = c * (1 - percent / 100);
    return (
      <svg width="88" height="88" viewBox="0 0 80 80" style={{ flexShrink: 0 }}>
        <circle cx="40" cy="40" r={r} fill="none" stroke="rgba(255,255,255,0.05)" strokeWidth="8"/>
        <circle cx="40" cy="40" r={r} fill="none" stroke={color} strokeWidth="8" strokeLinecap="round"
          strokeDasharray={c} strokeDashoffset={off} transform="rotate(-90 40 40)"/>
        <text x="40" y="46" textAnchor="middle" fontFamily="IBM Plex Mono" fontSize="15" fontWeight="600" fill="white">{percent}%</text>
      </svg>
    );
  };

  const renderMultiDonut = (segments: { v: number, c: string }[], label: string) => {
    const total = segments.reduce((sum, s) => sum + s.v, 0);
    const r = 32;
    const c = 2 * Math.PI * r;
    let offset = 0;
    return (
      <svg width="88" height="88" viewBox="0 0 80 80" style={{ flexShrink: 0 }}>
        <circle cx="40" cy="40" r={r} fill="none" stroke="rgba(255,255,255,0.05)" strokeWidth="8"/>
        {segments.map((s, i) => {
          const len = c * (s.v / total);
          const currentOffset = offset;
          offset += len;
          return (
            <circle key={i} cx="40" cy="40" r={r} fill="none" stroke={s.c} strokeWidth="8"
              strokeDasharray={`${len} ${c - len}`} strokeDashoffset={-currentOffset} transform="rotate(-90 40 40)"/>
          );
        })}
        <text x="40" y="46" textAnchor="middle" fontFamily="IBM Plex Mono" fontSize="14" fontWeight="600" fill="white">{label}</text>
      </svg>
    );
  };

  const handleSendMessage = () => {
    if (!chatInput.trim()) return;
    const time = new Date().toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' });
    setChatMessages([...chatMessages, { text: chatInput, isOut: true, time }]);
    setChatInput('');
  };

  const moveTask = (task: string, from: 'todo' | 'progress' | 'done', to: 'todo' | 'progress' | 'done') => {
    setTasks({
      ...tasks,
      [from]: tasks[from].filter(t => t !== task),
      [to]: [...tasks[to], task]
    });
  };

  // --- Dynamic Tab Routing within Dashboard Hub ---
  if (activeTab === 'documents') return <CapturePage />;
  if (activeTab === 'factures') return <InvoiceListPage />;
  if (activeTab === 'securite') return <AdminPage />;

  // ---------------------------------------------------------------------------
  // CLIENT PERSPECTIVE
  // ---------------------------------------------------------------------------
  if (demoRole === 'client') {
    switch (activeTab) {
      case 'dossier':
        return (
          <div className="dossier-tab">
            <div className="page-head">
              <div>
                <h1>Mon dossier</h1>
                <div className="sub">Clôture exercice 2025 — Société Générale SARL</div>
              </div>
            </div>
            <div className="capture-container">
              <div className="card panel glass-card">
                <div className="panel-head"><h3>Progression</h3></div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '24px', marginBottom: '1.5rem' }}>
                  {renderDonut(75, 'var(--blue)')}
                  <div style={{ flex: 1 }}>
                    <div className="list-sub" style={{ marginBottom: '8px' }}>Dernière mise à jour : 29 mai 2026, par Sarah Jlassi</div>
                    <div className="bar-track"><div className="bar-fill" style={{ width: '75%', background: 'var(--blue)' }}></div></div>
                  </div>
                </div>
                <div className="panel-head"><h3>Historique des étapes</h3></div>
                {[
                  { t: "Collecte des pièces terminée", d: "24/05/2026", s: "Validé" },
                  { t: "Écritures et rapprochement", d: "26/05/2026", s: "Validé" },
                  { t: "Contrôle de conformité en cours", d: "29/05/2026", s: "À vérifier" },
                  { t: "Validation par l'expert-comptable", d: "À venir", s: "Nouveau" },
                  { t: "Mise à disposition des livrables", d: "À venir", s: "Nouveau" }
                ].map((item: any, i: number) => (
                  <div key={i} className="list-row">
                    <div className="list-icon" style={{ background: 'var(--blue-soft)', color: 'var(--blue)' }}><Folder size={15} /></div>
                    <div className="list-main"><div className="list-title">{item.t}</div></div>
                    <div className="list-end">
                      {getStatusBadge(item.s)}
                      <div className="list-time">{item.d}</div>
                    </div>
                  </div>
                ))}
              </div>
              <div className="card panel glass-card">
                <div className="panel-head"><h3>Pièces attendues</h3></div>
                {[
                  { t: "RIB actualisé", d: "Échéance 05/06/2026" },
                  { t: "Justificatif d'assurance", d: "Échéance 10/06/2026" }
                ].map((item: any, i: number) => (
                  <div key={i} className="list-row">
                    <div className="list-icon" style={{ background: 'var(--red-soft)', color: 'var(--red)' }}><AlertTriangle size={15} /></div>
                    <div className="list-main">
                      <div className="list-title">{item.t}</div>
                      <div className="list-sub">{item.d}</div>
                    </div>
                    <button className="btn btn-outline btn-sm" onClick={() => navigate('/documents')}>Déposer</button>
                  </div>
                ))}
                <div className="panel-head mt14" style={{ marginTop: '1.5rem' }}><h3>Responsable du dossier</h3></div>
                <div className="list-row">
                  <div className="row-avatar avatar-large" style={{ background: '#3b7ddb' }}>SJ</div>
                  <div className="list-main">
                    <div className="list-title">Sarah Jlassi</div>
                    <div className="list-sub">Comptable senior · Répond sous 24h</div>
                  </div>
                  <button className="btn btn-primary btn-sm" onClick={() => navigate('/messagerie')}>Contacter</button>
                </div>
              </div>
            </div>
          </div>
        );
      case 'echeances':
        return (
          <div className="echeances-tab">
            <div className="page-head">
              <div>
                <h1>Mes échéances</h1>
                <div className="sub">Vos prochaines échéances fiscales, sociales et contractuelles</div>
              </div>
            </div>
            <div className="card panel glass-card" style={{ maxWidth: '800px' }}>
              {mockupEcheances.map((e: any, i: number) => (
                <div key={i} className="list-row">
                  <div className="list-icon" style={{ 
                    background: e.statut === 'Urgent' ? 'var(--red-soft)' : 'var(--gold-soft)', 
                    color: e.statut === 'Urgent' ? 'var(--red)' : '#fbbf24' 
                  }}>
                    <Clock size={15} />
                  </div>
                  <div className="list-main">
                    <div className="list-title">{e.label}</div>
                    <div className="list-sub">{e.date}</div>
                  </div>
                  <div className="list-end">
                    <div className="list-amount">{money(e.montant)}</div>
                    {getStatusBadge(e.statut)}
                  </div>
                </div>
              ))}
            </div>
          </div>
        );
      case 'messagerie':
        return (
          <div className="messagerie-tab">
            <div className="page-head">
              <div>
                <h1>Messagerie</h1>
                <div className="sub">Échanges directs avec votre comptable</div>
              </div>
            </div>
            <div className="card glass-card">
              <div className="chat-wrap">
                <div className="chat-list">
                  <div className="chat-item active">
                    <div className="row-avatar" style={{ background: '#f4841f', marginRight: 0 }}>SJ</div>
                    <div style={{ flex: 1, minWidth: 0, marginLeft: '10px' }}>
                      <div className="flex-between">
                        <div className="list-title">Sarah Jlassi</div>
                        <div className="list-time">En ligne</div>
                      </div>
                      <div className="list-sub" style={{ textOverflow: 'ellipsis', overflow: 'hidden', whiteSpace: 'nowrap' }}>
                        {chatMessages[chatMessages.length - 1]?.text}
                      </div>
                    </div>
                  </div>
                </div>
                <div className="chat-body">
                  <div className="chat-header">
                    <div className="row-avatar" style={{ background: '#f4841f', marginRight: 0 }}>SJ</div>
                    <div>
                      <div className="list-title">Sarah Jlassi</div>
                      <div className="list-sub">Comptable senior</div>
                    </div>
                  </div>
                  <div className="chat-messages">
                    {chatMessages.map((msg: any, i: number) => (
                      <div key={i} className={`msg ${msg.isOut ? 'out' : 'in'}`}>
                        {msg.text}
                        <div className="msg-time">{msg.time}</div>
                      </div>
                    ))}
                  </div>
                  <div className="chat-input">
                    <input 
                      type="text" 
                      placeholder="Écrire un message…" 
                      value={chatInput} 
                      onChange={e => setChatInput(e.target.value)}
                      onKeyDown={e => e.key === 'Enter' && handleSendMessage()}
                    />
                    <button className="btn btn-primary" onClick={handleSendMessage}><Send size={15} /></button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        );
      case 'rdv':
        return (
          <div className="rdv-tab">
            <div className="page-head">
              <div>
                <h1>Rendez-vous</h1>
                <div className="sub">Demandez, confirmez ou reportez un rendez-vous avec le cabinet</div>
              </div>
              <button className="btn btn-primary"><Plus size={15} /> Demander un rendez-vous</button>
            </div>
            <div className="capture-container">
              <div className="card panel glass-card">
                <div className="panel-head"><h3>À venir</h3></div>
                <div className="list-row">
                  <div className="list-icon" style={{ background: 'var(--blue-soft)', color: 'var(--blue)' }}><Calendar size={15} /></div>
                  <div className="list-main">
                    <div className="list-title">Revue de clôture 2025</div>
                    <div className="list-sub">Avec Sarah Jlassi · Visioconférence</div>
                  </div>
                  <div className="list-end">
                    <div className="list-title">05/06/2026</div>
                    <div className="list-time">14:30</div>
                  </div>
                </div>
                <div className="list-row">
                  <div className="list-icon" style={{ background: 'var(--blue-soft)', color: 'var(--blue)' }}><Calendar size={15} /></div>
                  <div className="list-main">
                    <div className="list-title">Point fiscal trimestriel</div>
                    <div className="list-sub">Avec Amira Bouaziz · Au cabinet</div>
                  </div>
                  <div className="list-end">
                    <div className="list-title">18/06/2026</div>
                    <div className="list-time">10:00</div>
                  </div>
                </div>
              </div>
              <div className="card panel glass-card">
                <div className="panel-head"><h3>Historique</h3></div>
                <div className="list-row">
                  <div className="list-icon" style={{ background: 'var(--green-soft)', color: 'var(--green)' }}><Calendar size={15} /></div>
                  <div className="list-main">
                    <div className="list-title">Lancement du dossier 2025</div>
                    <div className="list-sub">03/03/2026</div>
                  </div>
                  {getStatusBadge('Validé')}
                </div>
              </div>
            </div>
          </div>
        );
      case 'parametres':
        return (
          <div className="parametres-tab">
            <div className="page-head">
              <div>
                <h1>Paramètres</h1>
                <div className="sub">Informations de connexion et préférences</div>
              </div>
            </div>
            <div className="capture-container">
              <div className="card panel glass-card">
                <div className="panel-head"><h3>Authentification</h3></div>
                <div className="list-row">
                  <div className="list-main">
                    <div className="list-title">Adresse e-mail</div>
                    <div className="list-sub">ahmed.benali@societegenerale-sarl.tn</div>
                  </div>
                  <button className="btn btn-outline btn-sm">Modifier</button>
                </div>
                <div className="list-row">
                  <div className="list-main">
                    <div className="list-title">Mot de passe</div>
                    <div className="list-sub">Dernière modification il y a 3 mois</div>
                  </div>
                  <button className="btn btn-outline btn-sm">Réinitialiser</button>
                </div>
                <div className="list-row">
                  <div className="list-main">
                    <div className="list-title">Authentification multifacteur</div>
                    <div className="list-sub">Recommandée pour sécuriser votre compte</div>
                  </div>
                  <span className="badge b-grey">Désactivée</span>
                </div>
              </div>
              <div className="card panel glass-card">
                <div className="panel-head"><h3>Notifications</h3></div>
                {["Document déposé ou refusé", "Échéance proche", "Nouveau message du cabinet", "Facture impayée"].map((t: string, i: number) => (
                  <div key={i} className="list-row">
                    <div className="list-main"><div className="list-title">{t}</div></div>
                    <span className="badge b-green">In-app + e-mail</span>
                  </div>
                ))}
              </div>
            </div>
          </div>
        );
      case 'dashboard':
      default:
        return (
          <div className="client-dashboard">
            <div className="page-head">
              <div>
                <h1>Bonjour, Ahmed 👋</h1>
                <div className="sub">Bienvenue dans votre espace client CEO-IT — Société Générale SARL</div>
              </div>
              <div className="head-actions">
                <button className="btn btn-primary" onClick={() => navigate('/documents')}><Plus size={15} /> Déposer un document</button>
              </div>
            </div>

            <div className="kpi-grid">
              <div className="kpi-card glass-card">
                <div className="kpi-icon" style={{ background: 'var(--blue-soft)', color: 'var(--blue)' }}><FileText size={20} /></div>
                <div className="kpi-data">
                  <h3>Documents</h3>
                  <div className="kpi-value">28</div>
                  <div className="kpi-delta up">↑ +3 cette semaine</div>
                </div>
              </div>
              <div className="kpi-card glass-card">
                <div className="kpi-icon" style={{ background: 'var(--red-soft)', color: 'var(--red)' }}><DollarSign size={20} /></div>
                <div className="kpi-data">
                  <h3>Factures impayées</h3>
                  <div className="kpi-value">2</div>
                  <div className="kpi-delta warn">1 250 TND en attente</div>
                </div>
              </div>
              <div className="kpi-card glass-card">
                <div className="kpi-icon" style={{ background: 'var(--gold-soft)', color: 'var(--gold)' }}><Calendar size={20} /></div>
                <div className="kpi-data">
                  <h3>Prochaine échéance</h3>
                  <div className="kpi-value">12 juin</div>
                  <div className="kpi-delta warn">TVA — 950 TND</div>
                </div>
              </div>
              <div className="kpi-card glass-card">
                <div className="kpi-icon" style={{ background: 'var(--orange-soft)', color: 'var(--orange)' }}><MessageSquare size={20} /></div>
                <div className="kpi-data">
                  <h3>Messages non lus</h3>
                  <div className="kpi-value">2</div>
                  <div className="kpi-delta up">Cabinet CEO-IT</div>
                </div>
              </div>
            </div>

            <div className="capture-container">
              <div className="card panel glass-card">
                <div className="panel-head"><h3>Avancement du dossier</h3><span className="link" onClick={() => navigate('/dossier')} style={{ cursor: 'pointer' }}>Voir mon dossier</span></div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '20px', marginBottom: '1.5rem' }}>
                  {renderDonut(75, 'var(--blue)')}
                  <div style={{ flex: 1 }}>
                    <div className="list-title" style={{ fontSize: '14px' }}>Clôture exercice 2025 — en cours</div>
                    <div className="list-sub" style={{ marginBottom: '8px' }}>Étape actuelle : contrôle de conformité par le cabinet</div>
                    <div className="bar-track"><div className="bar-fill" style={{ width: '75%', background: 'var(--blue)' }}></div></div>
                    <div className="tag-row">
                      <span className="badge b-green"><span className="dot"></span>Collecte terminée</span>
                      <span className="badge b-gold"><span className="dot"></span>En révision</span>
                      <span className="badge b-grey"><span className="dot"></span>Clôture à venir</span>
                    </div>
                  </div>
                </div>
                <div className="panel-head"><h3>Déposer un document</h3></div>
                <div className="dropzone" onClick={() => navigate('/documents')} style={{ cursor: 'pointer' }}>
                  <div className="dz-icon" style={{ background: 'var(--blue-soft)', color: 'var(--blue)' }}><Plus size={20} /></div>
                  <div className="dz-title">Glissez-déposez vos fichiers ici</div>
                  <div className="dz-sub">ou cliquez pour parcourir · PDF, JPG, PNG (max. 10 Mo)</div>
                </div>
              </div>

              <div className="card panel glass-card">
                <div className="panel-head"><h3>Messages récents</h3><span className="link" onClick={() => navigate('/messagerie')} style={{ cursor: 'pointer' }}>Tout voir</span></div>
                {chatMessages.slice(-3).reverse().map((m: any, i: number) => (
                  <div key={i} className="list-row" onClick={() => navigate('/messagerie')} style={{ cursor: 'pointer' }}>
                    <div className="row-avatar" style={{ background: '#f4841f' }}>SJ</div>
                    <div className="list-main">
                      <div className="list-title">Sarah Jlassi</div>
                      <div className="list-sub">{m.text}</div>
                    </div>
                    <div className="list-end"><div className="list-time">{m.time}</div></div>
                  </div>
                ))}
                <div className="panel-head" style={{ marginTop: '1.5rem' }}><h3>Dernières factures</h3><span className="link" onClick={() => navigate('/factures')} style={{ cursor: 'pointer' }}>Voir toutes</span></div>
                {mockupFactures.slice(0, 3).map((f: any, i: number) => (
                  <div key={i} className="list-row">
                    <div className="list-icon" style={{ background: 'var(--blue-soft)', color: 'var(--blue)' }}><FileText size={15} /></div>
                    <div className="list-main">
                      <div className="list-title">{f.num}</div>
                      <div className="list-sub">{f.date}</div>
                    </div>
                    <div className="list-end">
                      <div className="list-amount">{money(f.montant)}</div>
                      {getStatusBadge(f.statut)}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        );
    }
  }

  // ---------------------------------------------------------------------------
  // COLLABORATEUR PERSPECTIVE
  // ---------------------------------------------------------------------------
  if (demoRole === 'comptable') {
    switch (activeTab) {
      case 'dossiers':
        return (
          <div className="dossiers-tab">
            <div className="page-head">
              <div>
                <h1>Dossiers attribués</h1>
                <div className="sub">Clients et dossiers dont vous êtes responsable ou contributeur</div>
              </div>
            </div>
            <div className="card glass-card">
              <div className="table-responsive">
                <table className="data-table">
                  <thead>
                    <tr>
                      <th>Client</th>
                      <th>Secteur</th>
                      <th>Statut</th>
                      <th>Solde dû</th>
                      <th>Action</th>
                    </tr>
                  </thead>
                  <tbody>
                    {mockupClients.map((c: any, i: number) => (
                      <tr key={i}>
                        <td>
                          <span className="row-avatar" style={{ background: initialsColor(c.name) }}>{getInitials(c.name)}</span>
                          <span className="cell-strong">{c.name}</span>
                        </td>
                        <td>{c.secteur}</td>
                        <td>{getStatusBadge(c.statut)}</td>
                        <td className="cell-mono">{c.solde ? money(c.solde) : '—'}</td>
                        <td><button className="btn btn-outline btn-sm">Ouvrir</button></td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        );
      case 'comptabilite':
        return (
          <div className="comptabilite-tab">
            <div className="page-head">
              <div>
                <h1>Comptabilité</h1>
                <div className="sub">Saisie des écritures et rapprochement bancaire</div>
              </div>
              <button className="btn btn-primary"><Plus size={15} /> Nouvelle écriture</button>
            </div>
            <div className="capture-container">
              <div className="card glass-card">
                <div className="panel-head" style={{ padding: '1rem' }}><h3 style={{ fontSize: '14px' }}>Journal des écritures — Mai 2026</h3></div>
                <table className="data-table">
                  <thead>
                    <tr>
                      <th>Date</th>
                      <th>Libellé</th>
                      <th>Compte</th>
                      <th>Débit</th>
                      <th>Crédit</th>
                    </tr>
                  </thead>
                  <tbody>
                    {[
                      ["28/05", "Achats de marchandises — STB", "607000", "2 450", ""],
                      ["27/05", "Règlement fournisseur — DGS", "401000", "", "980"],
                      ["27/05", "Facture client — LBG", "411000", "1 350", ""],
                      ["26/05", "Charges diverses — ALPHA", "628000", "3 200", ""],
                      ["25/05", "Encaissement client — SGS", "512000", "4 800", ""]
                    ].map((row: string[], i: number) => (
                      <tr key={i}>
                        <td className="cell-mono">{row[0]}</td>
                        <td>{row[1]}</td>
                        <td className="cell-mono">{row[2]}</td>
                        <td className="cell-mono">{row[3]}</td>
                        <td className="cell-mono">{row[4]}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
              <div className="card panel glass-card">
                <div className="panel-head"><h3>Rapprochement bancaire</h3></div>
                <div className="banner info">
                  <BookOpen size={18} />
                  <div>
                    <div className="banner-title">BIAT — Compte courant DGS</div>
                    <div className="banner-text">42 lignes importées · 38 rapprochées automatiquement · 4 écarts à traiter</div>
                  </div>
                </div>
                <div className="bar-track" style={{ marginBottom: '1.5rem' }}><div className="bar-fill" style={{ width: '90%', background: 'var(--green)' }}></div></div>
                <div className="panel-head"><h3>Écarts détectés</h3></div>
                <div className="list-row">
                  <div className="list-icon" style={{ background: 'var(--red-soft)', color: 'var(--red)' }}><AlertTriangle size={15} /></div>
                  <div className="list-main">
                    <div className="list-title">Virement non identifié</div>
                    <div className="list-sub">1 200 TND · 24/05/2026</div>
                  </div>
                  <button className="btn btn-outline btn-sm">Lettrer</button>
                </div>
                <div className="list-row">
                  <div className="list-icon" style={{ background: 'var(--red-soft)', color: 'var(--red)' }}><AlertTriangle size={15} /></div>
                  <div className="list-main">
                    <div className="list-title">Double prélèvement suspecté</div>
                    <div className="list-sub">450 TND · 22/05/2026</div>
                  </div>
                  <button className="btn btn-outline btn-sm">Lettrer</button>
                </div>
              </div>
            </div>
          </div>
        );
      case 'taches':
        return (
          <div className="taches-tab">
            <div className="page-head">
              <div>
                <h1>Gestion des tâches</h1>
                <div className="sub">Organisez vos travaux et livrables cabinets</div>
              </div>
            </div>
            <div className="capture-container" style={{ gridTemplateColumns: 'repeat(3, 1fr)' }}>
              <div className="card panel glass-card">
                <div className="panel-head">
                  <h3 style={{ color: 'var(--text-secondary)' }}>À faire</h3>
                  <span className="badge b-grey">{tasks.todo.length}</span>
                </div>
                {tasks.todo.map((t: string, i: number) => (
                  <div key={i} className="list-row">
                    <div className="list-main"><div className="list-title">{t}</div></div>
                    <button className="btn btn-outline btn-sm" style={{ padding: '2px 6px', fontSize: '0.75rem' }} onClick={() => moveTask(t, 'todo', 'progress')}>Démarrer</button>
                  </div>
                ))}
              </div>
              <div className="card panel glass-card">
                <div className="panel-head">
                  <h3 style={{ color: 'var(--orange)' }}>En cours</h3>
                  <span className="badge b-orange">{tasks.progress.length}</span>
                </div>
                {tasks.progress.map((t: string, i: number) => (
                  <div key={i} className="list-row">
                    <div className="list-main"><div className="list-title">{t}</div></div>
                    <button className="btn btn-outline btn-sm" style={{ padding: '2px 6px', fontSize: '0.75rem' }} onClick={() => moveTask(t, 'progress', 'done')}>Terminer</button>
                  </div>
                ))}
              </div>
              <div className="card panel glass-card">
                <div className="panel-head">
                  <h3 style={{ color: 'var(--green)' }}>Terminé</h3>
                  <span className="badge b-green">{tasks.done.length}</span>
                </div>
                {tasks.done.map((t: string, i: number) => (
                  <div key={i} className="list-row">
                    <div className="list-main"><div className="list-title" style={{ textDecoration: 'line-through', opacity: 0.6 }}>{t}</div></div>
                    <span className="badge b-green"><CheckCircle size={12} /> Fait</span>
                  </div>
                ))}
              </div>
            </div>
          </div>
        );
      case 'dashboard':
      default:
        return (
          <div className="user-dashboard">
            <div className="page-head">
              <div>
                <h1>Mon espace de travail</h1>
                <div className="sub">Bonjour Sarah — voici un aperçu de vos activités et tâches en cours</div>
              </div>
            </div>
            <div className="kpi-grid">
              <div className="kpi-card glass-card">
                <div className="kpi-icon" style={{ background: 'var(--orange-soft)', color: 'var(--orange)' }}><Folder size={20} /></div>
                <div className="kpi-data">
                  <h3>Dossiers attribués</h3>
                  <div className="kpi-value">28</div>
                  <div className="kpi-delta up">Tous actifs</div>
                </div>
              </div>
              <div className="kpi-card glass-card">
                <div className="kpi-icon" style={{ background: 'var(--gold-soft)', color: 'var(--gold)' }}><FileText size={20} /></div>
                <div className="kpi-data">
                  <h3>Documents à vérifier</h3>
                  <div className="kpi-value">16</div>
                  <div className="kpi-delta warn">Affichés par date</div>
                </div>
              </div>
              <div className="kpi-card glass-card">
                <div className="kpi-icon" style={{ background: 'var(--blue-soft)', color: 'var(--blue)' }}><FileCheck size={20} /></div>
                <div className="kpi-data">
                  <h3>Factures à traiter</h3>
                  <div className="kpi-value">12</div>
                  <div className="kpi-delta warn">18 650 TND</div>
                </div>
              </div>
              <div className="kpi-card glass-card">
                <div className="kpi-icon" style={{ background: 'var(--red-soft)', color: 'var(--red)' }}><Clock size={20} /></div>
                <div className="kpi-data">
                  <h3>Échéances à venir</h3>
                  <div className="kpi-value">7</div>
                  <div className="kpi-delta warn">9 480 TND</div>
                </div>
              </div>
            </div>

            <div className="capture-container">
              <div className="card panel glass-card">
                <div className="panel-head"><h3>Dossiers attribués</h3><span className="link" onClick={() => navigate('/dossiers')} style={{ cursor: 'pointer' }}>Afficher tous</span></div>
                {mockupClients.slice(0, 5).map((c: any, i: number) => (
                  <div key={i} className="list-row">
                    <div className="row-avatar" style={{ background: initialsColor(c.name) }}>{getInitials(c.name)}</div>
                    <div className="list-main">
                      <div className="list-title">{c.name}</div>
                      <div className="list-sub">{c.secteur}</div>
                    </div>
                    <div className="list-end">{getStatusBadge(c.statut)}</div>
                  </div>
                ))}
                <div className="panel-head" style={{ marginTop: '1.5rem' }}><h3>Documents récents reçus</h3><span className="link" onClick={() => navigate('/documents')} style={{ cursor: 'pointer' }}>Voir la liste</span></div>
                {mockupDocuments.slice(2, 6).map((d: any, i: number) => (
                  <div key={i} className="list-row">
                    <div className="list-icon" style={{ background: 'var(--orange-soft)', color: 'var(--orange)' }}><FileText size={15} /></div>
                    <div className="list-main">
                      <div className="list-title">{d.nom}</div>
                      <div className="list-sub">{d.client}</div>
                    </div>
                    <div className="list-end">{getStatusBadge(d.statut)}</div>
                  </div>
                ))}
              </div>

              <div className="card panel glass-card">
                <div className="panel-head"><h3>Tâches assignées</h3><span className="link" onClick={() => navigate('/taches')} style={{ cursor: 'pointer' }}>Voir toutes</span></div>
                {tasks.todo.concat(tasks.progress).slice(0, 5).map((t: string, i: number) => (
                  <div key={i} className="list-row">
                    <input type="checkbox" style={{ width: '16px', height: '16px', accentColor: 'var(--orange)', cursor: 'pointer' }} onChange={() => {}} />
                    <div className="list-main" style={{ marginLeft: '8px' }}>
                      <div className="list-title">{t}</div>
                    </div>
                    <span className="badge b-gold"><span className="dot"></span>En attente</span>
                  </div>
                ))}

                <div className="panel-head" style={{ marginTop: '1.5rem' }}><h3>Workflow des dossiers</h3></div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '20px' }}>
                  {renderMultiDonut([
                    { v: 6, c: '#1e9e6b' },
                    { v: 14, c: '#3b7ddb' },
                    { v: 5, c: '#f0b429' },
                    { v: 3, c: '#8f6fe0' }
                  ], '28')}
                  <div style={{ flex: 1 }}>
                    <div className="legend-row"><span className="legend-dot" style={{ background: '#1e9e6b' }}></span>Clôturés <span className="lv">6 (21%)</span></div>
                    <div className="legend-row"><span className="legend-dot" style={{ background: '#3b7ddb' }}></span>En cours <span className="lv">14 (50%)</span></div>
                    <div className="legend-row"><span className="legend-dot" style={{ background: '#f0b429' }}></span>En révision <span className="lv">5 (18%)</span></div>
                    <div className="legend-row"><span className="legend-dot" style={{ background: '#8f6fe0' }}></span>Collecte <span className="lv">3 (11%)</span></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        );
    }
  }

  // ---------------------------------------------------------------------------
  // ADMINISTRATEUR PERSPECTIVE
  // ---------------------------------------------------------------------------
  switch (activeTab) {
    case 'rapports':
      return (
        <div className="rapports-tab">
          <div className="page-head">
            <div>
              <h1>Rapports administratifs</h1>
              <div className="sub">Rapports exportables selon votre niveau d'autorisation cabinet</div>
            </div>
          </div>
          <div className="capture-container" style={{ gridTemplateColumns: 'repeat(3, 1fr)' }}>
            {[
              { t: "Chiffre d'affaires & rentabilité", s: "Encaissements, impayés, rentabilité par période" },
              { t: "Dossiers & délais", s: "Dossiers traités, en retard, bloqués par dossier" },
              { t: "Charge de travail", s: "Temps de traitement moyen par collaborateur" },
              { t: "Volumes documentaires", s: "Erreurs OCR, taux d'extraction, doublons" },
              { t: "Conformité & fraude", s: "Scores de risque et décisions finales utilisateurs" },
              { t: "Audit & sécurité", s: "Journaux de connexion, actions sensibles, exports" }
            ].map((item: any, i: number) => (
              <div key={i} className="card panel glass-card">
                <div className="kpi-icon" style={{ background: 'var(--gold-soft)', color: 'var(--gold)', width: '36px', height: '36px', display: 'flex', alignItems: 'center', justifyContent: 'center', borderRadius: '8px', marginBottom: '12px' }}><TrendingUp size={18} /></div>
                <div className="list-title" style={{ fontSize: '13.5px' }}>{item.t}</div>
                <div className="list-sub" style={{ marginTop: '4px', marginBottom: '12px' }}>{item.s}</div>
                <div style={{ display: 'flex', gap: '8px' }}>
                  <button className="btn btn-outline btn-sm">PDF</button>
                  <button className="btn btn-outline btn-sm">Excel</button>
                  <button className="btn btn-outline btn-sm">CSV</button>
                </div>
              </div>
            ))}
          </div>
        </div>
      );
    case 'clients':
      return (
        <div className="clients-tab">
          <div className="page-head">
            <div>
              <h1>Annuaire des clients</h1>
              <div className="sub">Liste des entités juridiques sous contrat avec le cabinet</div>
            </div>
            <button className="btn btn-primary"><Plus size={15} /> Nouveau client</button>
          </div>
          <div className="card glass-card">
            <div className="table-responsive">
              <table className="data-table">
                <thead>
                  <tr>
                    <th>Raison sociale</th>
                    <th>Sigle</th>
                    <th>Secteur</th>
                    <th>Statut</th>
                    <th>Solde dû</th>
                  </tr>
                </thead>
                <tbody>
                  {mockupClients.map((c: any, i: number) => (
                    <tr key={i}>
                      <td>
                        <span className="row-avatar" style={{ background: initialsColor(c.name) }}>{getInitials(c.name)}</span>
                        <span className="cell-strong">{c.name}</span>
                      </td>
                      <td className="cell-mono">{c.sigle}</td>
                      <td>{c.secteur}</td>
                      <td>{getStatusBadge(c.statut)}</td>
                      <td className="cell-mono">{c.solde ? money(c.solde) : '—'}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      );
    case 'utilisateurs':
      return (
        <div className="utilisateurs-tab">
          <div className="page-head">
            <div>
              <h1>Collaborateurs du cabinet</h1>
              <div className="sub">Utilisateurs internes, affectation et charge de travail</div>
            </div>
            <button className="btn btn-primary"><Plus size={15} /> Ajouter un utilisateur</button>
          </div>
          <div className="card glass-card">
            <table className="data-table">
              <thead>
                <tr>
                  <th>Nom</th>
                  <th>Rôle</th>
                  <th>Dossiers</th>
                  <th>Charge de travail</th>
                  <th>Statut</th>
                </tr>
              </thead>
              <tbody>
                {mockupCollaborateurs.map((c: any, i: number) => (
                  <tr key={i}>
                    <td>
                      <span className="row-avatar" style={{ background: c.couleur }}>{getInitials(c.name)}</span>
                      <span className="cell-strong">{c.name}</span>
                    </td>
                    <td>{c.role}</td>
                    <td className="cell-mono">{c.dossiers} dossiers</td>
                    <td>
                      <div className="bar-track" style={{ width: '90px', display: 'inline-block', verticalAlign: 'middle', marginRight: '8px' }}><div className="bar-fill" style={{ width: `${c.charge}%`, background: c.couleur }}></div></div>
                      <span className="cell-mono">{c.charge}%</span>
                    </td>
                    <td>{getStatusBadge('Actif')}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      );
    case 'fiscalite':
      return (
        <div className="fiscalite-tab">
          <div className="page-head">
            <div>
              <h1>Fiscalité & Règles</h1>
              <div className="sub">Moteurs de calculs et règles configurées par juridiction</div>
            </div>
          </div>
          <div className="capture-container">
            <div className="card panel glass-card">
              <div className="panel-head"><h3>Contrôles actifs (24)</h3></div>
              {[
                { t: "TVA — Régime normal", j: "Tunisie", s: "Validé" },
                { t: "IS — Impôts sociétés", j: "Tunisie", s: "Validé" },
                { t: "Retenue à la source", j: "Tunisie", s: "Validé" },
                { t: "TVA — Régime forfaitaire", j: "Tunisie", s: "À vérifier" }
              ].map((r: any, i: number) => (
                <div key={i} className="list-row">
                  <div className="list-icon" style={{ background: 'var(--gold-soft)', color: '#f0b429' }}><BookOpen size={15} /></div>
                  <div className="list-main">
                    <div className="list-title">{r.t}</div>
                    <div className="list-sub">{r.j}</div>
                  </div>
                  {getStatusBadge(r.s)}
                </div>
              ))}
            </div>
            <div className="card panel glass-card">
              <div className="panel-head"><h3>Déclarations fiscales prêtes</h3></div>
              {[
                { t: "Déclaration TVA — STB", p: "Mai 2026", r: "Amira Bouaziz" },
                { t: "IS Acompte — Alpha Industrie", p: "T2 2026", r: "Amira Bouaziz" },
                { t: "CNSS — Digital Solutions", p: "Mai 2026", r: "Imen Trabelsi" }
              ].map((d: any, i: number) => (
                <div key={i} className="list-row">
                  <div className="list-main">
                    <div className="list-title">{d.t}</div>
                    <div className="list-sub">{d.p} · Préparé par {d.r}</div>
                  </div>
                  <button className="btn btn-outline btn-sm">Valider</button>
                </div>
              ))}
            </div>
          </div>
        </div>
      );
    case 'dashboard':
    default:
      return (
        <div className="admin-dashboard">
          <div className="page-head">
            <div>
              <h1>Tableau de bord de direction</h1>
              <div className="sub">Vue d'ensemble et pilotage du cabinet — Mai 2026</div>
            </div>
          </div>

          <div className="kpi-grid" style={{ gridTemplateColumns: 'repeat(6, 1fr)' }}>
            <div className="kpi-card glass-card" style={{ padding: '1rem', flexDirection: 'column', alignItems: 'flex-start', gap: '5px' }}>
              <div className="kpi-label" style={{ fontSize: '0.75rem', color: '#94a3b8', textTransform: 'uppercase', letterSpacing: '.04em' }}>Clients actifs</div>
              <div className="kpi-value" style={{ fontSize: '1.4rem' }}>152</div>
              <div className="kpi-delta up" style={{ fontSize: '0.75rem' }}>↑ +12 ce mois</div>
            </div>
            <div className="kpi-card glass-card" style={{ padding: '1rem', flexDirection: 'column', alignItems: 'flex-start', gap: '5px' }}>
              <div className="kpi-label" style={{ fontSize: '0.75rem', color: '#94a3b8', textTransform: 'uppercase', letterSpacing: '.04em' }}>Dossiers</div>
              <div className="kpi-value" style={{ fontSize: '1.4rem' }}>87</div>
              <div className="kpi-delta up" style={{ fontSize: '0.75rem' }}>↑ +8 ce mois</div>
            </div>
            <div className="kpi-card glass-card" style={{ padding: '1rem', flexDirection: 'column', alignItems: 'flex-start', gap: '5px' }}>
              <div className="kpi-label" style={{ fontSize: '0.75rem', color: '#94a3b8', textTransform: 'uppercase', letterSpacing: '.04em' }}>Équipe</div>
              <div className="kpi-value" style={{ fontSize: '1.4rem' }}>24</div>
              <div className="kpi-delta up" style={{ fontSize: '0.75rem' }}>↑ +2 ce mois</div>
            </div>
            <div className="kpi-card glass-card" style={{ padding: '1rem', flexDirection: 'column', alignItems: 'flex-start', gap: '5px' }}>
              <div className="kpi-label" style={{ fontSize: '0.75rem', color: '#94a3b8', textTransform: 'uppercase', letterSpacing: '.04em' }}>Factures impayées</div>
              <div className="kpi-value" style={{ fontSize: '1.4rem', whiteSpace: 'nowrap' }}>24.8K TND</div>
              <div className="kpi-delta down" style={{ fontSize: '0.75rem' }}>↓ 8 factures</div>
            </div>
            <div className="kpi-card glass-card" style={{ padding: '1rem', flexDirection: 'column', alignItems: 'flex-start', gap: '5px' }}>
              <div className="kpi-label" style={{ fontSize: '0.75rem', color: '#94a3b8', textTransform: 'uppercase', letterSpacing: '.04em' }}>Échéances fiscales</div>
              <div className="kpi-value" style={{ fontSize: '1.4rem', whiteSpace: 'nowrap' }}>7.3K TND</div>
              <div className="kpi-delta warn" style={{ fontSize: '0.75rem' }}>• 5 échéances</div>
            </div>
            <div className="kpi-card glass-card" style={{ padding: '1rem', flexDirection: 'column', alignItems: 'flex-start', gap: '5px' }}>
              <div className="kpi-label" style={{ fontSize: '0.75rem', color: '#94a3b8', textTransform: 'uppercase', letterSpacing: '.04em' }}>Tâches à valider</div>
              <div className="kpi-value" style={{ fontSize: '1.4rem' }}>18</div>
              <div className="kpi-delta warn" style={{ fontSize: '0.75rem' }}>• 6 urgentes</div>
            </div>
          </div>

          <div className="capture-container" style={{ marginBottom: '2rem' }}>
            <div className="card panel glass-card">
              <div className="panel-head"><h3>Indicateurs clés</h3><span className="badge b-blue">CA vs Encaissements</span></div>
              <div style={{ height: '220px' }}>
                <Line 
                  data={{
                    labels: ['Jan', 'Fév', 'Mar', 'Avr', 'Mai'],
                    datasets: [
                      {
                        label: "Chiffre d'affaires (TND)",
                        data: [92000, 101000, 97000, 118000, 128500],
                        borderColor: '#3d2170',
                        backgroundColor: 'rgba(61,33,112,0.1)',
                        tension: 0.4,
                        fill: true
                      },
                      {
                        label: 'Encaissements (TND)',
                        data: [80000, 88000, 91000, 99000, 110000],
                        borderColor: '#f4841f',
                        backgroundColor: 'rgba(244,132,31,0.05)',
                        tension: 0.4,
                        fill: true
                      }
                    ]
                  }}
                  options={{
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                      legend: { display: false }
                    },
                    scales: {
                      x: { grid: { display: false } },
                      y: { grid: { color: 'rgba(255,255,255,0.05)' } }
                    }
                  }}
                />
              </div>
            </div>

            <div className="card panel glass-card">
              <div className="panel-head"><h3>Répartition du chiffre d'affaires</h3></div>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '20px', height: '170px' }}>
                <div style={{ width: '130px', height: '130px' }}>
                  <Doughnut 
                    data={{
                      labels: ['Comptabilité', 'Fiscalité', 'Paie & RH', 'Conseil'],
                      datasets: [{
                        data: [45, 25, 20, 10],
                        backgroundColor: ['#3d2170', '#3b7ddb', '#f4841f', '#f0b429'],
                        borderWidth: 0
                      }]
                    }}
                    options={{
                      responsive: true,
                      maintainAspectRatio: false,
                      cutout: '70%',
                      plugins: {
                        legend: { display: false }
                      }
                    }}
                  />
                </div>
                <div style={{ flex: 1 }}>
                  <div className="legend-row"><span className="legend-dot" style={{ background: '#3d2170' }}></span>Comptabilité <span className="lv">45%</span></div>
                  <div className="legend-row"><span className="legend-dot" style={{ background: '#3b7ddb' }}></span>Fiscalité <span className="lv">25%</span></div>
                  <div className="legend-row"><span className="legend-dot" style={{ background: '#f4841f' }}></span>Paie & RH <span className="lv">20%</span></div>
                  <div className="legend-row"><span className="legend-dot" style={{ background: '#f0b429' }}></span>Conseil <span className="lv">10%</span></div>
                </div>
              </div>
            </div>
          </div>

          <div className="capture-container" style={{ gridTemplateColumns: 'repeat(3, 1fr)', marginBottom: '2rem' }}>
            <div className="card panel glass-card">
              <div className="panel-head"><h3>Factures impayées</h3><span className="link" onClick={() => navigate('/factures')} style={{ cursor: 'pointer' }}>Voir toutes</span></div>
              {mockupFactures.filter((f: any) => f.statut !== 'Payée').slice(0, 4).map((f: any, i: number) => (
                <div key={i} className="list-row">
                  <div className="list-main">
                    <div className="list-title">{f.client}</div>
                    <div className="list-sub">Échéance : {f.date}</div>
                  </div>
                  <div className="list-end">
                    <div className="list-amount">{money(f.montant)}</div>
                    {getStatusBadge(f.statut)}
                  </div>
                </div>
              ))}
            </div>

            <div className="card panel glass-card">
              <div className="panel-head"><h3>Charge de travail</h3><span className="link" onClick={() => navigate('/utilisateurs')} style={{ cursor: 'pointer' }}>Gérer l'équipe</span></div>
              {mockupCollaborateurs.slice(0, 4).map((c: any, i: number) => (
                <div key={i} style={{ marginBottom: '14px' }}>
                  <div className="flex-between" style={{ marginBottom: '4px' }}>
                    <span className="list-title" style={{ fontSize: '0.85rem' }}>{c.name}</span>
                    <span className="list-sub mono" style={{ fontSize: '0.85rem' }}>{c.charge}%</span>
                  </div>
                  <div className="bar-track"><div className="bar-fill" style={{ width: `${c.charge}%`, background: c.couleur }}></div></div>
                </div>
              ))}
            </div>

            <div className="card panel glass-card">
              <div className="panel-head"><h3>Alertes de fraude</h3><span className="link" onClick={() => navigate('/securite')} style={{ cursor: 'pointer' }}>Voir toutes</span></div>
              {mockupAlertesFraude.slice(0, 4).map((a: any, i: number) => (
                <div key={i} className="list-row" onClick={() => navigate('/securite')} style={{ cursor: 'pointer' }}>
                  <div className="list-icon" style={{ background: 'var(--red-soft)', color: 'var(--red)' }}><ShieldAlert size={15} /></div>
                  <div className="list-main">
                    <div className="list-title">{a.type}</div>
                    <div className="list-sub">{a.detail}</div>
                  </div>
                  {getStatusBadge(a.niveau)}
                </div>
              ))}
            </div>
          </div>

          <div className="capture-container">
            <div className="card panel glass-card">
              <div className="panel-head"><h3>Documents en attente</h3><span className="link" onClick={() => navigate('/documents')} style={{ cursor: 'pointer' }}>Gérer</span></div>
              {[
                { t: "Contrats", s: "12 documents" },
                { t: "Pièces comptables", s: "28 documents" },
                { t: "Bulletins de paie", s: "15 documents" }
              ].map((doc: any, i: number) => (
                <div key={i} className="list-row">
                  <div className="list-icon" style={{ background: 'var(--gold-soft)', color: 'var(--gold)' }}><FileText size={15} /></div>
                  <div className="list-main">
                    <div className="list-title">{doc.t}</div>
                    <div className="list-sub">{doc.s}</div>
                  </div>
                </div>
              ))}
            </div>

            <div className="card panel glass-card">
              <div className="panel-head"><h3>Activités en direct (BDD Réelle)</h3></div>
              <div className="scroll-y" style={{ maxHeight: '220px', overflowY: 'auto' }}>
                {facturesReal.slice(0, 4).map((f: any) => (
                  <div key={f.id} className="list-row">
                    <div className="list-icon" style={{ background: f.conformite_valide ? 'var(--green-soft)' : 'var(--red-soft)', color: f.conformite_valide ? 'var(--green)' : 'var(--red)' }}>
                      <FileText size={15} />
                    </div>
                    <div className="list-main">
                      <div className="list-title">Facture #{f.numero || f.id} — {f.fournisseur}</div>
                      <div className="list-sub">
                        Risque fraude : {f.fraude_score}% · {f.conformite_valide ? 'Conforme' : 'Non conforme'}
                      </div>
                    </div>
                    <div className="list-end">
                      <div className="list-amount">{f.ttc} {f.devise}</div>
                      <div className="list-time">{f.date_facture}</div>
                    </div>
                  </div>
                ))}
                {facturesReal.length === 0 && (
                  <div className="empty-state">Aucune activité enregistrée en BDD.</div>
                )}
              </div>
            </div>
          </div>
        </div>
      );
  }
};

export default Dashboard;
