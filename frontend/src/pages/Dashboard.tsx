import React, { useState, useEffect, useContext } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import { AuthContext } from '../context/AuthContext';
import api from '../api';
import CapturePage from './CapturePage';
import InvoiceListPage from './InvoiceListPage';
import AdminPage from './AdminPage';
import { Line, Doughnut } from 'react-chartjs-2';
import { 
  Chart as ChartJS, CategoryScale, LinearScale, PointElement, 
  LineElement, Title, Tooltip, Legend, ArcElement, Filler
} from 'chart.js';
import { 
  Folder, FileText, Clock, MessageSquare, Calendar, 
  ShieldAlert, DollarSign, TrendingUp, Plus, Send, 
  BookOpen, CheckCircle, AlertTriangle, FileCheck, Users
} from 'lucide-react';

ChartJS.register(CategoryScale, LinearScale, PointElement, LineElement, Title, Tooltip, Legend, ArcElement, Filler);

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
  const [sliderValue, setSliderValue] = useState(85);

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
        const facturesRes = await api.get('/factures');
        setFacturesReal(facturesRes.data);
      } catch (err) {
        console.error("Error loading backend data", err);
      }
    };
    fetchData();
  }, []);

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
    const colors = ["#b199f8", "#d48a52", "#bbfb95", "#8f6fe0", "#e14b4b", "#f0b429", "#3d2170"];
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
        <circle cx="40" cy="40" r={r} fill="none" stroke="#e5e5eb" strokeWidth="8"/>
        <circle cx="40" cy="40" r={r} fill="none" stroke={color} strokeWidth="8" strokeLinecap="round"
          strokeDasharray={c} strokeDashoffset={off} transform="rotate(-90 40 40)"/>
        <text x="40" y="46" textAnchor="middle" fontFamily="IBM Plex Mono" fontSize="15" fontWeight="600" fill="var(--text-primary)">{percent}%</text>
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
        <circle cx="40" cy="40" r={r} fill="none" stroke="#e5e5eb" strokeWidth="8"/>
        {segments.map((s, i) => {
          const len = c * (s.v / total);
          const currentOffset = offset;
          offset += len;
          return (
            <circle key={i} cx="40" cy="40" r={r} fill="none" stroke={s.c} strokeWidth="8"
              strokeDasharray={`${len} ${c - len}`} strokeDashoffset={-currentOffset} transform="rotate(-90 40 40)"/>
          );
        })}
        <text x="40" y="46" textAnchor="middle" fontFamily="IBM Plex Mono" fontSize="14" fontWeight="600" fill="var(--text-primary)">{label}</text>
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
            <div className="page-head" style={{ marginBottom: '2rem' }}>
              <h1>Mon dossier</h1>
              <p className="text-secondary">Clôture exercice 2025 — Société Générale SARL</p>
            </div>
            <div className="capture-container">
              <div className="card panel">
                <div className="panel-head"><h3>Progression</h3></div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '24px', marginBottom: '1.5rem' }}>
                  {renderDonut(75, 'var(--secondary)')}
                  <div style={{ flex: 1 }}>
                    <div className="list-sub" style={{ marginBottom: '8px' }}>Dernière mise à jour : 29 mai 2026, par Sarah Jlassi</div>
                    <div className="bar-track"><div className="bar-fill" style={{ width: '75%', background: 'var(--secondary)' }}></div></div>
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
                    <div className="list-icon" style={{ background: 'rgba(177, 153, 248, 0.1)', color: 'var(--secondary)' }}><Folder size={15} /></div>
                    <div className="list-main"><div className="list-title">{item.t}</div></div>
                    <div className="list-end">
                      {getStatusBadge(item.s)}
                      <div className="list-time">{item.d}</div>
                    </div>
                  </div>
                ))}
              </div>
              <div className="card panel">
                <div className="panel-head"><h3>Pièces attendues</h3></div>
                {[
                  { t: "RIB actualisé", d: "Échéance 05/06/2026" },
                  { t: "Justificatif d'assurance", d: "Échéance 10/06/2026" }
                ].map((item: any, i: number) => (
                  <div key={i} className="list-row">
                    <div className="list-icon" style={{ background: 'rgba(248,113,113,0.1)', color: 'var(--error)' }}><AlertTriangle size={15} /></div>
                    <div className="list-main">
                      <div className="list-title">{item.t}</div>
                      <div className="list-sub">{item.d}</div>
                    </div>
                    <button className="btn btn-outline btn-sm" onClick={() => navigate('/documents')}>Déposer</button>
                  </div>
                ))}
                <div className="panel-head mt14" style={{ marginTop: '1.5rem' }}><h3>Responsable du dossier</h3></div>
                <div className="list-row">
                  <div className="row-avatar avatar-large" style={{ background: 'var(--secondary)' }}>SJ</div>
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
            <div className="page-head" style={{ marginBottom: '2rem' }}>
              <h1>Mes échéances</h1>
              <p className="text-secondary">Vos prochaines échéances fiscales, sociales et contractuelles</p>
            </div>
            <div className="card panel" style={{ maxWidth: '800px' }}>
              {mockupEcheances.map((e: any, i: number) => (
                <div key={i} className="list-row">
                  <div className="list-icon" style={{ 
                    background: e.statut === 'Urgent' ? 'rgba(248,113,113,0.1)' : 'rgba(251,191,36,0.1)', 
                    color: e.statut === 'Urgent' ? 'var(--error)' : 'var(--warning)' 
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
            <div className="page-head" style={{ marginBottom: '2rem' }}>
              <h1>Messagerie</h1>
              <p className="text-secondary">Échanges directs avec votre comptable</p>
            </div>
            <div className="chat-wrap">
              <div className="chat-list">
                <div className="chat-item active">
                  <div className="row-avatar" style={{ background: 'var(--glow-orange)', marginRight: 0 }}>SJ</div>
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
                  <div className="row-avatar" style={{ background: 'var(--glow-orange)' }}>SJ</div>
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
                    placeholder="Écrire un message..." 
                    value={chatInput} 
                    onChange={e => setChatInput(e.target.value)}
                    onKeyDown={e => e.key === 'Enter' && handleSendMessage()}
                  />
                  <button className="btn btn-primary btn-sm" onClick={handleSendMessage}><Send size={15} /></button>
                </div>
              </div>
            </div>
          </div>
        );
      case 'rdv':
        return (
          <div className="rdv-tab">
            <div className="page-head" style={{ marginBottom: '2rem', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div>
                <h1>Rendez-vous</h1>
                <p className="text-secondary">Demandez, confirmez ou reportez un rendez-vous avec le cabinet</p>
              </div>
              <button className="btn btn-primary"><Plus size={16} /> Demander un rendez-vous</button>
            </div>
            <div className="capture-container">
              <div className="card panel">
                <div className="panel-head"><h3>À venir</h3></div>
                <div className="list-row">
                  <div className="list-icon" style={{ background: 'rgba(187,251,149,0.1)', color: 'var(--primary)' }}><Calendar size={15} /></div>
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
                  <div className="list-icon" style={{ background: 'rgba(187,251,149,0.1)', color: 'var(--primary)' }}><Calendar size={15} /></div>
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
              <div className="card panel">
                <div className="panel-head"><h3>Historique</h3></div>
                <div className="list-row">
                  <div className="list-icon" style={{ background: 'rgba(0,0,0,0.04)', color: 'var(--text-muted)' }}><Calendar size={15} /></div>
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
            <div className="page-head" style={{ marginBottom: '2rem' }}>
              <h1>Paramètres</h1>
              <p className="text-secondary">Informations de connexion et préférences</p>
            </div>
            <div className="capture-container">
              <div className="card panel">
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
              <div className="card panel">
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
            <div className="mytasky-grid">
              <div className="mytasky-header-row">
                <div className="mytasky-welcome">
                  <h1>Bonjour, Ahmed ⚡</h1>
                  <p>Bienvenue dans votre espace client CEO-IT — Société Générale SARL</p>
                </div>
                <div className="quick-pills">
                  <div className="quick-pill" onClick={() => navigate('/documents')}>
                    <div className="qp-icon" style={{ background: 'var(--primary)' }}><Plus size={20} color="#000" /></div>
                    <div className="qp-text">
                      <h4>Déposer</h4>
                      <p>Facture, RIB, contrats</p>
                    </div>
                  </div>
                </div>
              </div>

              <div style={{ gridColumn: 'span 2', display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '1.5rem', marginBottom: '1rem' }}>
                {/* Card 1: Documents (Dark Charcoal) */}
                <div className="card panel" style={{ background: 'var(--kpi-charcoal)', border: 'none', color: '#ffffff', padding: '1.5rem', display: 'flex', flexDirection: 'column', gap: '8px', borderRadius: 'var(--radius)' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <span style={{ fontSize: '0.85rem', color: '#9ca3af', fontWeight: 600 }}>Documents</span>
                    <div style={{ width: '28px', height: '28px', background: 'rgba(255,255,255,0.08)', borderRadius: '6px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><FileText size={14} color="#ffffff" /></div>
                  </div>
                  <div style={{ fontSize: '1.8rem', fontWeight: 800 }}>28</div>
                  <div style={{ fontSize: '0.75rem', color: '#10b981', fontWeight: 600 }}>↑ +3 <span style={{ color: '#9ca3af' }}>cette semaine</span></div>
                </div>

                {/* Card 2: Factures Impayées (Soft Mint) */}
                <div className="card panel" style={{ background: 'var(--kpi-mint)', border: 'none', color: 'var(--text-primary)', padding: '1.5rem', display: 'flex', flexDirection: 'column', gap: '8px', borderRadius: 'var(--radius)' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <span style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', fontWeight: 600 }}>Factures Impayées</span>
                    <div style={{ width: '28px', height: '28px', background: 'rgba(13, 148, 136, 0.08)', borderRadius: '6px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><DollarSign size={14} color="var(--kpi-mint-text)" /></div>
                  </div>
                  <div style={{ fontSize: '1.8rem', fontWeight: 800, color: '#12100f' }}>2</div>
                  <div style={{ fontSize: '0.75rem', color: 'var(--kpi-mint-text)', fontWeight: 600 }}>1 250 TND <span style={{ color: 'var(--text-muted)' }}>en attente</span></div>
                </div>

                {/* Card 3: Prochaine Échéance (Soft Pink) */}
                <div className="card panel" style={{ background: 'var(--kpi-pink)', border: 'none', color: 'var(--text-primary)', padding: '1.5rem', display: 'flex', flexDirection: 'column', gap: '8px', borderRadius: 'var(--radius)' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <span style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', fontWeight: 600 }}>Prochaine Échéance</span>
                    <div style={{ width: '28px', height: '28px', background: 'rgba(219, 39, 119, 0.08)', borderRadius: '6px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Calendar size={14} color="var(--kpi-pink-text)" /></div>
                  </div>
                  <div style={{ fontSize: '1.8rem', fontWeight: 800, color: '#12100f' }}>12 Juin</div>
                  <div style={{ fontSize: '0.75rem', color: 'var(--kpi-pink-text)', fontWeight: 600 }}>TVA <span style={{ color: 'var(--text-muted)' }}>— 950 TND</span></div>
                </div>

                {/* Card 4: Messages Non Lus (Soft Blue) */}
                <div className="card panel" style={{ background: 'var(--kpi-blue)', border: 'none', color: 'var(--text-primary)', padding: '1.5rem', display: 'flex', flexDirection: 'column', gap: '8px', borderRadius: 'var(--radius)' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <span style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', fontWeight: 600 }}>Messages Non Lus</span>
                    <div style={{ width: '28px', height: '28px', background: 'rgba(37, 99, 235, 0.08)', borderRadius: '6px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><MessageSquare size={14} color="var(--kpi-blue-text)" /></div>
                  </div>
                  <div style={{ fontSize: '1.8rem', fontWeight: 800, color: '#12100f' }}>2</div>
                  <div style={{ fontSize: '0.75rem', color: 'var(--kpi-blue-text)', fontWeight: 600 }}>Cabinet <span style={{ color: 'var(--text-muted)' }}>CEO-IT</span></div>
                </div>
              </div>

              {/* Left Column: Dossier avancement & Upload */}
              <div className="card panel" style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
                <div className="panel-head">
                  <h3>Avancement du dossier</h3>
                  <span className="link" onClick={() => navigate('/dossier')} style={{ cursor: 'pointer' }}>Voir mon dossier</span>
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '20px', marginBottom: '1rem' }}>
                  {renderDonut(75, 'var(--secondary)')}
                  <div style={{ flex: 1 }}>
                    <div className="list-title" style={{ fontSize: '14px' }}>Clôture exercice 2025 — en cours</div>
                    <div className="list-sub" style={{ marginBottom: '8px' }}>Étape actuelle : contrôle de conformité par le cabinet</div>
                    <div className="bar-track"><div className="bar-fill" style={{ width: '75%', background: 'var(--secondary)' }}></div></div>
                    <div className="tag-row">
                      <span className="badge b-green"><span className="dot"></span>Collecte terminée</span>
                      <span className="badge b-gold"><span className="dot"></span>En révision</span>
                    </div>
                  </div>
                </div>
                
                <div className="panel-head" style={{ marginTop: '1rem' }}><h3>Déposer un document</h3></div>
                <div className="dropzone" onClick={() => navigate('/documents')} style={{ cursor: 'pointer' }}>
                  <div className="dz-icon" style={{ background: 'rgba(177,153,248,0.1)', color: 'var(--secondary)' }}><Plus size={20} /></div>
                  <div className="dz-title">Glissez-déposez vos fichiers ici</div>
                  <div className="dz-sub">ou cliquez pour parcourir · PDF, JPG, PNG</div>
                </div>
              </div>

              {/* Right Column: Messages & Invoices (White High Contrast Card) */}
              <div className="card panel" style={{ display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>
                <div>
                  <div className="panel-head">
                    <h3 style={{ color: '#12100f' }}>Messages récents</h3>
                    <span className="link" onClick={() => navigate('/messagerie')} style={{ cursor: 'pointer', color: 'var(--secondary)' }}>Tout voir</span>
                  </div>
                  {chatMessages.slice(-2).reverse().map((m: any, i: number) => (
                    <div key={i} className="list-row" onClick={() => navigate('/messagerie')} style={{ cursor: 'pointer', borderColor: 'rgba(0,0,0,0.06)' }}>
                      <div className="row-avatar" style={{ background: 'var(--glow-orange)' }}>SJ</div>
                      <div className="list-main">
                        <div className="list-title" style={{ color: '#12100f' }}>Sarah Jlassi</div>
                        <div className="list-sub" style={{ color: '#6a6664' }}>{m.text}</div>
                      </div>
                      <div className="list-end"><div className="list-time" style={{ color: '#6a6664' }}>{m.time}</div></div>
                    </div>
                  ))}
                </div>

                <div>
                  <div className="panel-head" style={{ marginTop: '1rem' }}>
                    <h3 style={{ color: '#12100f' }}>Dernières factures</h3>
                    <span className="link" onClick={() => navigate('/factures')} style={{ cursor: 'pointer', color: 'var(--secondary)' }}>Voir toutes</span>
                  </div>
                  {mockupFactures.slice(0, 3).map((f: any, i: number) => (
                    <div key={i} className="list-row" style={{ borderColor: 'rgba(0,0,0,0.06)' }}>
                      <div className="list-icon" style={{ background: 'rgba(0,0,0,0.05)', color: '#000' }}><FileText size={15} /></div>
                      <div className="list-main">
                        <div className="list-title" style={{ color: '#12100f' }}>{f.num}</div>
                        <div className="list-sub" style={{ color: '#6a6664' }}>{f.date}</div>
                      </div>
                      <div className="list-end">
                        <div className="list-amount" style={{ color: '#12100f' }}>{money(f.montant)}</div>
                        {getStatusBadge(f.statut)}
                      </div>
                    </div>
                  ))}
                </div>
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
            <div className="page-head" style={{ marginBottom: '2rem' }}>
              <h1>Dossiers attribués</h1>
              <p className="text-secondary">Clients et dossiers dont vous êtes responsable ou contributeur</p>
            </div>
            <div className="card glass-card" style={{ background: 'var(--card-bg)' }}>
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
            <div className="page-head" style={{ marginBottom: '2rem', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div>
                <h1>Comptabilité</h1>
                <p className="text-secondary">Saisie des écritures et rapprochement bancaire</p>
              </div>
              <button className="btn btn-primary"><Plus size={16} /> Nouvelle écriture</button>
            </div>
            <div className="capture-container">
              <div className="card panel">
                <div className="panel-head"><h3>Journal des écritures — Mai 2026</h3></div>
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
              <div className="card panel">
                <div className="panel-head"><h3>Rapprochement bancaire</h3></div>
                <div className="banner info">
                  <BookOpen size={18} />
                  <div>
                    <div className="banner-title">BIAT — Compte courant DGS</div>
                    <div className="banner-text">42 lignes importées · 38 rapprochées automatiquement · 4 écarts à traiter</div>
                  </div>
                </div>
                <div className="bar-track" style={{ marginBottom: '1.5rem' }}><div className="bar-fill" style={{ width: '90%', background: 'var(--primary)' }}></div></div>
                <div className="panel-head"><h3>Écarts détectés</h3></div>
                <div className="list-row">
                  <div className="list-icon" style={{ background: 'rgba(248,113,113,0.1)', color: 'var(--error)' }}><AlertTriangle size={15} /></div>
                  <div className="list-main">
                    <div className="list-title">Virement non identifié</div>
                    <div className="list-sub">1 200 TND · 24/05/2026</div>
                  </div>
                  <button className="btn btn-outline btn-sm">Lettrer</button>
                </div>
                <div className="list-row">
                  <div className="list-icon" style={{ background: 'rgba(248,113,113,0.1)', color: 'var(--error)' }}><AlertTriangle size={15} /></div>
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
            <div className="page-head" style={{ marginBottom: '2rem' }}>
              <h1>Gestion des tâches</h1>
              <p className="text-secondary">Organisez vos travaux et livrables cabinets</p>
            </div>
            <div className="capture-container" style={{ gridTemplateColumns: 'repeat(3, 1fr)' }}>
              <div className="card panel">
                <div className="panel-head">
                  <h3 style={{ color: 'var(--text-secondary)' }}>À faire</h3>
                  <span className="badge b-grey">{tasks.todo.length}</span>
                </div>
                {tasks.todo.map((t: string, i: number) => (
                  <div key={i} className="list-row" style={{ flexDirection: 'column', alignItems: 'flex-start', gap: '8px' }}>
                    <div className="list-main"><div className="list-title">{t}</div></div>
                    <button className="btn btn-outline btn-sm full-width" onClick={() => moveTask(t, 'todo', 'progress')}>Démarrer</button>
                  </div>
                ))}
              </div>
              <div className="card panel">
                <div className="panel-head">
                  <h3 style={{ color: 'var(--glow-orange)' }}>En cours</h3>
                  <span className="badge b-orange">{tasks.progress.length}</span>
                </div>
                {tasks.progress.map((t: string, i: number) => (
                  <div key={i} className="list-row" style={{ flexDirection: 'column', alignItems: 'flex-start', gap: '8px' }}>
                    <div className="list-main"><div className="list-title">{t}</div></div>
                    <button className="btn btn-outline btn-sm full-width" onClick={() => moveTask(t, 'progress', 'done')}>Terminer</button>
                  </div>
                ))}
              </div>
              <div className="card panel">
                <div className="panel-head">
                  <h3 style={{ color: 'var(--primary)' }}>Terminé</h3>
                  <span className="badge b-green">{tasks.done.length}</span>
                </div>
                {tasks.done.map((t: string, i: number) => (
                  <div key={i} className="list-row">
                    <div className="list-main"><div className="list-title" style={{ textDecoration: 'line-through', opacity: 0.5 }}>{t}</div></div>
                    <span className="badge b-green" style={{ marginLeft: 'auto' }}><CheckCircle size={12} /> Fait</span>
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
            <div className="mytasky-grid">
              <div className="mytasky-header-row">
                <div className="mytasky-welcome">
                  <h1>Bonjour, Sarah 👋</h1>
                  <p>Voici un aperçu de vos activités et tâches en cours.</p>
                </div>
                <div className="quick-pills">
                  <div className="quick-pill" onClick={() => navigate('/documents')}>
                    <div className="qp-icon" style={{ background: 'var(--primary)' }}><Plus size={20} color="#000" /></div>
                    <div className="qp-text">
                      <h4>Capture</h4>
                      <p>Lancer OCR IA</p>
                    </div>
                  </div>
                </div>
              </div>

              <div style={{ gridColumn: 'span 2', display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '1.5rem', marginBottom: '1rem' }}>
                {/* Card 1: Dossiers Attribués (Dark Charcoal) */}
                <div className="card panel" style={{ background: 'var(--kpi-charcoal)', border: 'none', color: '#ffffff', padding: '1.5rem', display: 'flex', flexDirection: 'column', gap: '8px', borderRadius: 'var(--radius)' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <span style={{ fontSize: '0.85rem', color: '#9ca3af', fontWeight: 600 }}>Dossiers Attribués</span>
                    <div style={{ width: '28px', height: '28px', background: 'rgba(255,255,255,0.08)', borderRadius: '6px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Folder size={14} color="#ffffff" /></div>
                  </div>
                  <div style={{ fontSize: '1.8rem', fontWeight: 800 }}>28</div>
                  <div style={{ fontSize: '0.75rem', color: '#10b981', fontWeight: 600 }}>↑ +2 <span style={{ color: '#9ca3af' }}>ce mois</span></div>
                </div>

                {/* Card 2: Docs à Vérifier (Soft Mint) */}
                <div className="card panel" style={{ background: 'var(--kpi-mint)', border: 'none', color: 'var(--text-primary)', padding: '1.5rem', display: 'flex', flexDirection: 'column', gap: '8px', borderRadius: 'var(--radius)' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <span style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', fontWeight: 600 }}>Docs à Vérifier</span>
                    <div style={{ width: '28px', height: '28px', background: 'rgba(13, 148, 136, 0.08)', borderRadius: '6px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><FileText size={14} color="var(--kpi-mint-text)" /></div>
                  </div>
                  <div style={{ fontSize: '1.8rem', fontWeight: 800, color: '#12100f' }}>16</div>
                  <div style={{ fontSize: '0.75rem', color: 'var(--kpi-mint-text)', fontWeight: 600 }}>Affichés <span style={{ color: 'var(--text-muted)' }}>par date</span></div>
                </div>

                {/* Card 3: Factures à Traiter (Soft Pink) */}
                <div className="card panel" style={{ background: 'var(--kpi-pink)', border: 'none', color: 'var(--text-primary)', padding: '1.5rem', display: 'flex', flexDirection: 'column', gap: '8px', borderRadius: 'var(--radius)' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <span style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', fontWeight: 600 }}>Factures à Traiter</span>
                    <div style={{ width: '28px', height: '28px', background: 'rgba(219, 39, 119, 0.08)', borderRadius: '6px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><FileCheck size={14} color="var(--kpi-pink-text)" /></div>
                  </div>
                  <div style={{ fontSize: '1.8rem', fontWeight: 800, color: '#12100f' }}>12</div>
                  <div style={{ fontSize: '0.75rem', color: 'var(--kpi-pink-text)', fontWeight: 600 }}>18 650 TND <span style={{ color: 'var(--text-muted)' }}>à valider</span></div>
                </div>

                {/* Card 4: Échéances à venir (Soft Blue) */}
                <div className="card panel" style={{ background: 'var(--kpi-blue)', border: 'none', color: 'var(--text-primary)', padding: '1.5rem', display: 'flex', flexDirection: 'column', gap: '8px', borderRadius: 'var(--radius)' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <span style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', fontWeight: 600 }}>Échéances à venir</span>
                    <div style={{ width: '28px', height: '28px', background: 'rgba(37, 99, 235, 0.08)', borderRadius: '6px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Clock size={14} color="var(--kpi-blue-text)" /></div>
                  </div>
                  <div style={{ fontSize: '1.8rem', fontWeight: 800, color: '#12100f' }}>7</div>
                  <div style={{ fontSize: '0.75rem', color: 'var(--kpi-blue-text)', fontWeight: 600 }}>9 480 TND <span style={{ color: 'var(--text-muted)' }}>total</span></div>
                </div>
              </div>

              {/* Left Column: Dossiers list & Documents */}
              <div className="card panel" style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
                <div className="panel-head">
                  <h3>Dossiers attribués</h3>
                  <span className="link" onClick={() => navigate('/dossiers')} style={{ cursor: 'pointer' }}>Afficher tous</span>
                </div>
                {mockupClients.slice(0, 3).map((c: any, i: number) => (
                  <div key={i} className="list-row">
                    <div className="row-avatar" style={{ background: initialsColor(c.name) }}>{getInitials(c.name)}</div>
                    <div className="list-main">
                      <div className="list-title">{c.name}</div>
                      <div className="list-sub">{c.secteur}</div>
                    </div>
                    <div className="list-end">{getStatusBadge(c.statut)}</div>
                  </div>
                ))}
                
                <div className="panel-head" style={{ marginTop: '1rem' }}>
                  <h3>Documents récents reçus</h3>
                  <span className="link" onClick={() => navigate('/documents')} style={{ cursor: 'pointer' }}>Voir la liste</span>
                </div>
                {mockupDocuments.slice(2, 5).map((d: any, i: number) => (
                  <div key={i} className="list-row">
                    <div className="list-icon" style={{ background: 'rgba(212,138,82,0.1)', color: 'var(--glow-orange)' }}><FileText size={15} /></div>
                    <div className="list-main">
                      <div className="list-title">{d.nom}</div>
                      <div className="list-sub">{d.client}</div>
                    </div>
                    <div className="list-end">{getStatusBadge(d.statut)}</div>
                  </div>
                ))}
              </div>

              {/* Right Column: Tasks checklist & Multi-donut (High Contrast White Card) */}
              <div className="card panel" style={{ display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>
                <div>
                  <div className="panel-head">
                    <h3 style={{ color: '#12100f' }}>Tâches assignées</h3>
                    <span className="link" onClick={() => navigate('/taches')} style={{ cursor: 'pointer', color: 'var(--secondary)' }}>Voir toutes</span>
                  </div>
                  {tasks.todo.slice(0, 3).map((t: string, i: number) => (
                    <div key={i} className="list-row" style={{ borderColor: 'rgba(0,0,0,0.06)' }}>
                      <input type="checkbox" style={{ width: '16px', height: '16px', accentColor: 'var(--glow-orange)', cursor: 'pointer' }} onChange={() => {}} />
                      <div className="list-main" style={{ marginLeft: '8px' }}>
                        <div className="list-title" style={{ color: '#12100f' }}>{t}</div>
                      </div>
                      <span className="badge b-gold"><span className="dot"></span>En attente</span>
                    </div>
                  ))}
                </div>

                <div>
                  <div className="panel-head">
                    <h3 style={{ color: '#12100f' }}>Workflow des dossiers</h3>
                  </div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '20px' }}>
                    {renderMultiDonut([
                      { v: 6, c: '#bbfb95' },
                      { v: 14, c: '#b199f8' },
                      { v: 5, c: '#f0b429' },
                      { v: 3, c: '#8f6fe0' }
                    ], '28')}
                    <div style={{ flex: 1 }}>
                      <div className="legend-row" style={{ color: '#12100f' }}><span className="legend-dot" style={{ background: '#bbfb95' }}></span>Clôturés <span className="lv" style={{ color: '#12100f' }}>6 (21%)</span></div>
                      <div className="legend-row" style={{ color: '#12100f' }}><span className="legend-dot" style={{ background: '#b199f8' }}></span>En cours <span className="lv" style={{ color: '#12100f' }}>14 (50%)</span></div>
                      <div className="legend-row" style={{ color: '#12100f' }}><span className="legend-dot" style={{ background: '#f0b429' }}></span>En révision <span className="lv" style={{ color: '#12100f' }}>5 (18%)</span></div>
                      <div className="legend-row" style={{ color: '#12100f' }}><span className="legend-dot" style={{ background: '#8f6fe0' }}></span>Collecte <span className="lv" style={{ color: '#12100f' }}>3 (11%)</span></div>
                    </div>
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
          <div className="page-head" style={{ marginBottom: '2rem' }}>
            <h1>Rapports administratifs</h1>
            <p className="text-secondary">Rapports exportables selon votre niveau d'autorisation cabinet</p>
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
              <div key={i} className="card panel" style={{ display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
                <div>
                  <div className="kpi-icon" style={{ background: 'rgba(251,191,36,0.1)', color: 'var(--warning)', width: '36px', height: '36px', display: 'flex', alignItems: 'center', justifyContent: 'center', borderRadius: '8px', marginBottom: '12px' }}><TrendingUp size={18} /></div>
                  <div className="list-title" style={{ fontSize: '13.5px' }}>{item.t}</div>
                  <div className="list-sub" style={{ marginTop: '4px', marginBottom: '12px' }}>{item.s}</div>
                </div>
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
          <div className="page-head" style={{ marginBottom: '2rem', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div>
              <h1>Annuaire des clients</h1>
              <p className="text-secondary">Liste des entités juridiques sous contrat avec le cabinet</p>
            </div>
            <button className="btn btn-primary"><Plus size={16} /> Nouveau client</button>
          </div>
          <div className="card panel" style={{ padding: '1.5rem' }}>
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
          <div className="page-head" style={{ marginBottom: '2rem', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div>
              <h1>Collaborateurs du cabinet</h1>
              <p className="text-secondary">Utilisateurs internes, affectation et charge de travail</p>
            </div>
            <button className="btn btn-primary"><Plus size={16} /> Ajouter un utilisateur</button>
          </div>
          <div className="card panel" style={{ padding: '1.5rem' }}>
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
          <div className="page-head" style={{ marginBottom: '2rem' }}>
            <h1>Fiscalité & Règles</h1>
            <p className="text-secondary">Moteurs de calculs et règles configurées par juridiction</p>
          </div>
          <div className="capture-container">
            <div className="card panel">
              <div className="panel-head"><h3>Contrôles actifs (24)</h3></div>
              {[
                { t: "TVA — Régime normal", j: "Tunisie", s: "Validé" },
                { t: "IS — Impôts sociétés", j: "Tunisie", s: "Validé" },
                { t: "Retenue à la source", j: "Tunisie", s: "Validé" },
                { t: "TVA — Régime forfaitaire", j: "Tunisie", s: "À vérifier" }
              ].map((r: any, i: number) => (
                <div key={i} className="list-row">
                  <div className="list-icon" style={{ background: 'rgba(251,191,36,0.1)', color: '#f0b429' }}><BookOpen size={15} /></div>
                  <div className="list-main">
                    <div className="list-title">{r.t}</div>
                    <div className="list-sub">{r.j}</div>
                  </div>
                  {getStatusBadge(r.s)}
                </div>
              ))}
            </div>
            <div className="card panel">
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
          <div className="mytasky-grid">
            <div className="mytasky-header-row">
              <div className="mytasky-welcome">
                <h1>Tableau de bord de direction 📈</h1>
                <p>Vue d'ensemble et pilotage du cabinet — Mai 2026</p>
              </div>
            </div>

            {/* KPI Row (Clipped and styled inside a dark card layout) */}
            <div style={{ gridColumn: 'span 2', display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '1.5rem', marginBottom: '1rem' }}>
              {/* Card 1: Clients (Dark Charcoal) */}
              <div className="card panel" style={{ background: 'var(--kpi-charcoal)', border: 'none', color: '#ffffff', padding: '1.5rem', display: 'flex', flexDirection: 'column', gap: '8px', borderRadius: 'var(--radius)' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <span style={{ fontSize: '0.85rem', color: '#9ca3af', fontWeight: 600 }}>Clients</span>
                  <div style={{ width: '28px', height: '28px', background: 'rgba(255,255,255,0.08)', borderRadius: '6px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Users size={14} color="#ffffff" /></div>
                </div>
                <div style={{ fontSize: '1.8rem', fontWeight: 800 }}>152</div>
                <div style={{ fontSize: '0.75rem', color: '#10b981', fontWeight: 600 }}>↑ +12 <span style={{ color: '#9ca3af' }}>ce mois</span></div>
              </div>

              {/* Card 2: Dossiers Actifs (Soft Mint) */}
              <div className="card panel" style={{ background: 'var(--kpi-mint)', border: 'none', color: 'var(--text-primary)', padding: '1.5rem', display: 'flex', flexDirection: 'column', gap: '8px', borderRadius: 'var(--radius)' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <span style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', fontWeight: 600 }}>Dossiers Actifs</span>
                  <div style={{ width: '28px', height: '28px', background: 'rgba(13, 148, 136, 0.08)', borderRadius: '6px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Folder size={14} color="var(--kpi-mint-text)" /></div>
                </div>
                <div style={{ fontSize: '1.8rem', fontWeight: 800, color: '#12100f' }}>87</div>
                <div style={{ fontSize: '0.75rem', color: 'var(--kpi-mint-text)', fontWeight: 600 }}>↑ +8 <span style={{ color: 'var(--text-muted)' }}>ce mois</span></div>
              </div>

              {/* Card 3: CA Impayé (Soft Pink) */}
              <div className="card panel" style={{ background: 'var(--kpi-pink)', border: 'none', color: 'var(--text-primary)', padding: '1.5rem', display: 'flex', flexDirection: 'column', gap: '8px', borderRadius: 'var(--radius)' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <span style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', fontWeight: 600 }}>CA Impayé</span>
                  <div style={{ width: '28px', height: '28px', background: 'rgba(219, 39, 119, 0.08)', borderRadius: '6px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><DollarSign size={14} color="var(--kpi-pink-text)" /></div>
                </div>
                <div style={{ fontSize: '1.8rem', fontWeight: 800, color: '#12100f' }}>24.8K TND</div>
                <div style={{ fontSize: '0.75rem', color: 'var(--kpi-pink-text)', fontWeight: 600 }}>↓ 8 <span style={{ color: 'var(--text-muted)' }}>factures impayées</span></div>
              </div>

              {/* Card 4: Validation Requise (Soft Blue) */}
              <div className="card panel" style={{ background: 'var(--kpi-blue)', border: 'none', color: 'var(--text-primary)', padding: '1.5rem', display: 'flex', flexDirection: 'column', gap: '8px', borderRadius: 'var(--radius)' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <span style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', fontWeight: 600 }}>Validation Requise</span>
                  <div style={{ width: '28px', height: '28px', background: 'rgba(37, 99, 235, 0.08)', borderRadius: '6px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><FileCheck size={14} color="var(--kpi-blue-text)" /></div>
                </div>
                <div style={{ fontSize: '1.8rem', fontWeight: 800, color: '#12100f' }}>18</div>
                <div style={{ fontSize: '0.75rem', color: 'var(--kpi-blue-text)', fontWeight: 600 }}>• 6 <span style={{ color: 'var(--text-muted)' }}>urgentes</span></div>
              </div>
            </div>

            {/* Left Column: CA Charts */}
            <div className="card panel" style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
              <div className="panel-head"><h3>Indicateurs clés</h3><span className="badge b-blue">CA vs Encaissements</span></div>
              <div style={{ height: '220px' }}>
                <Line 
                  data={{
                    labels: ['Jan', 'Fév', 'Mar', 'Avr', 'Mai'],
                    datasets: [
                      {
                        label: "Chiffre d'affaires (TND)",
                        data: [92000, 101000, 97000, 118000, 128500],
                        borderColor: '#10b981',
                        backgroundColor: 'rgba(16, 185, 129, 0.05)',
                        tension: 0.4,
                        fill: true
                      },
                      {
                        label: 'Encaissements (TND)',
                        data: [80000, 88000, 91000, 99000, 110000],
                        borderColor: '#4f46e5',
                        backgroundColor: 'rgba(79, 70, 229, 0.05)',
                        tension: 0.4,
                        fill: true
                      }
                    ]
                  }}
                  options={{
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: {
                      x: { grid: { display: false } },
                      y: { grid: { color: '#e5e5eb' } }
                    }
                  }}
                />
              </div>

              {/* Autonomy Slider inside Direction Panel */}
              <div style={{ borderTop: '1px solid var(--card-border)', paddingTop: '1.5rem', marginTop: '1rem' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '0.5rem', alignItems: 'center' }}>
                  <h3 style={{ fontSize: '1rem', display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <ShieldAlert size={18} color="var(--primary)" /> 
                    AI Autonomy & Auto-validation Level
                  </h3>
                </div>
                <p className="text-secondary" style={{ fontSize: '0.8rem', marginBottom: '1.5rem' }}>Set the confidence limit above which invoice OCR is registered automatically without human bookkeeping.</p>
                
                <div className="ai-slider-wrapper" style={{ padding: '1rem 0 2rem' }}>
                  <label>
                    <input 
                      id="ai-autonomy-admin" 
                      type="range" 
                      min="0" max="100" 
                      value={sliderValue} 
                      onChange={(e) => setSliderValue(parseInt(e.target.value))}
                    />
                    <output htmlFor="ai-autonomy-admin" style={{ '--min': 0, '--max': 100 } as React.CSSProperties}><span></span></output>
                  </label>
                </div>
              </div>
            </div>

            {/* Right Column: Donut répartition & Fraud Alerts (White High Contrast Card) */}
            <div className="card panel" style={{ display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>
              <div>
                <div className="panel-head">
                  <h3 style={{ color: '#12100f' }}>Répartition du chiffre d'affaires</h3>
                </div>
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '20px', height: '170px' }}>
                  <div style={{ width: '130px', height: '130px' }}>
                    <Doughnut 
                      data={{
                        labels: ['Comptabilité', 'Fiscalité', 'Paie & RH', 'Conseil'],
                        datasets: [{
                          data: [45, 25, 20, 10],
                          backgroundColor: ['#bbfb95', '#b199f8', '#d48a52', '#6e6a68'],
                          borderWidth: 0
                        }]
                      }}
                      options={{
                        responsive: true,
                        maintainAspectRatio: false,
                        cutout: '70%',
                        plugins: { legend: { display: false } }
                      }}
                    />
                  </div>
                  <div style={{ flex: 1 }}>
                    <div className="legend-row" style={{ color: '#12100f' }}><span className="legend-dot" style={{ background: '#bbfb95' }}></span>Comptabilité <span className="lv" style={{ color: '#12100f' }}>45%</span></div>
                    <div className="legend-row" style={{ color: '#12100f' }}><span className="legend-dot" style={{ background: '#b199f8' }}></span>Fiscalité <span className="lv" style={{ color: '#12100f' }}>25%</span></div>
                    <div className="legend-row" style={{ color: '#12100f' }}><span className="legend-dot" style={{ background: '#d48a52' }}></span>Paie & RH <span className="lv" style={{ color: '#12100f' }}>20%</span></div>
                    <div className="legend-row" style={{ color: '#12100f' }}><span className="legend-dot" style={{ background: '#6e6a68' }}></span>Conseil <span className="lv" style={{ color: '#12100f' }}>10%</span></div>
                  </div>
                </div>
              </div>

              <div>
                <div className="panel-head">
                  <h3 style={{ color: '#12100f' }}>Alertes de fraude récentes</h3>
                  <span className="link" onClick={() => navigate('/securite')} style={{ cursor: 'pointer', color: 'var(--secondary)' }}>Voir toutes</span>
                </div>
                {mockupAlertesFraude.slice(0, 3).map((a: any, i: number) => (
                  <div key={i} className="list-row" onClick={() => navigate('/securite')} style={{ cursor: 'pointer', borderColor: 'rgba(0,0,0,0.06)' }}>
                    <div className="list-icon" style={{ background: 'rgba(0,0,0,0.05)', color: '#000' }}><ShieldAlert size={15} /></div>
                    <div className="list-main">
                      <div className="list-title" style={{ color: '#12100f' }}>{a.type}</div>
                      <div className="list-sub" style={{ color: '#6a6664' }}>{a.detail}</div>
                    </div>
                    {getStatusBadge(a.niveau)}
                  </div>
                ))}
              </div>
            </div>

            {/* Bottom Row: Unpaid Invoices, Team Charge, and BDD Activities */}
            <div className="card panel" style={{ gridColumn: 'span 2' }}>
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '1.5rem' }}>
                <div>
                  <div className="panel-head">
                    <h3>Factures impayées</h3>
                    <span className="link" onClick={() => navigate('/factures')} style={{ cursor: 'pointer' }}>Voir toutes</span>
                  </div>
                  {mockupFactures.filter((f: any) => f.statut !== 'Payée').slice(0, 3).map((f: any, i: number) => (
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

                <div>
                  <div className="panel-head">
                    <h3>Charge de travail équipe</h3>
                    <span className="link" onClick={() => navigate('/utilisateurs')} style={{ cursor: 'pointer' }}>Gérer l'équipe</span>
                  </div>
                  {mockupCollaborateurs.slice(0, 3).map((c: any, i: number) => (
                    <div key={i} style={{ marginBottom: '14px' }}>
                      <div className="flex-between" style={{ marginBottom: '4px' }}>
                        <span className="list-title" style={{ fontSize: '0.85rem' }}>{c.name}</span>
                        <span className="list-sub mono" style={{ fontSize: '0.85rem' }}>{c.charge}%</span>
                      </div>
                      <div className="bar-track"><div className="bar-fill" style={{ width: `${c.charge}%`, background: 'var(--secondary)' }}></div></div>
                    </div>
                  ))}
                </div>

                <div>
                  <div className="panel-head">
                    <h3>Activités en direct (BDD Réelle)</h3>
                  </div>
                  <div style={{ maxHeight: '180px', overflowY: 'auto' }}>
                    {facturesReal.slice(0, 3).map((f: any) => (
                      <div key={f.id} className="list-row">
                        <div className="list-icon" style={{ 
                          background: f.conformite_valide ? 'rgba(187,251,149,0.1)' : 'rgba(248,113,113,0.1)', 
                          color: f.conformite_valide ? 'var(--primary)' : 'var(--error)' 
                        }}>
                          <FileCheck size={15} />
                        </div>
                        <div className="list-main">
                          <div className="list-title" style={{ fontSize: '0.85rem' }}>{f.fournisseur || 'Facture #' + f.id}</div>
                          <div className="list-sub">Risque : {f.fraude_score}% · {f.conformite_valide ? 'Conforme' : 'Alerte'}</div>
                        </div>
                        <div className="list-end">
                          <div className="list-amount" style={{ fontSize: '0.85rem' }}>{f.ttc} {f.devise}</div>
                        </div>
                      </div>
                    ))}
                    {facturesReal.length === 0 && (
                      <div className="empty-state" style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>Aucune activité en BDD réelle.</div>
                    )}
                  </div>
                </div>
              </div>
            </div>

          </div>
        </div>
      );
  }
};

export default Dashboard;
