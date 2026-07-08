import { useContext, useState } from 'react';
import { Outlet, useNavigate, useLocation } from 'react-router-dom';
import { AuthContext } from '../context/AuthContext';
import { 
  LayoutDashboard, 
  Folder, 
  FileText, 
  Clock, 
  MessageSquare, 
  Calendar, 
  Settings, 
  LogOut, 
  Menu, 
  X, 
  BookOpen, 
  Users, 
  ShieldAlert, 
  TrendingUp,
  FileCheck
} from 'lucide-react';

const Layout = () => {
  const { logout, demoRole, setDemoRole } = useContext(AuthContext);
  const navigate = useNavigate();
  const location = useLocation();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  // Determine the active tab based on URL path
  const getActiveTab = () => {
    const path = location.pathname.substring(1); // remove leading slash
    if (path === 'capture') return 'documents';
    if (path === 'admin') return 'securite';
    return path || 'dashboard';
  };

  const activeTab = getActiveTab();

  const handleTabClick = (tabId: string) => {
    if (tabId === 'dashboard') {
      navigate('/');
    } else {
      navigate('/' + tabId);
    }
    setMobileMenuOpen(false);
  };

  // Define sidebar navigation configuration for each role
  const getNavConfig = () => {
    switch (demoRole) {
      case 'client':
        return [
          {
            section: 'Général',
            items: [
              { id: 'dashboard', label: 'Tableau de bord', icon: <LayoutDashboard size={18} /> },
              { id: 'dossier', label: 'Mon dossier', icon: <Folder size={18} /> },
            ]
          },
          {
            section: 'Documents & factures',
            items: [
              { id: 'documents', label: 'Documents', icon: <FileText size={18} />, count: 8 },
              { id: 'factures', label: 'Mes factures', icon: <FileCheck size={18} />, count: 2 },
              { id: 'echeances', label: 'Mes échéances', icon: <Clock size={18} />, count: 3 },
            ]
          },
          {
            section: 'Échanges',
            items: [
              { id: 'messagerie', label: 'Messagerie', icon: <MessageSquare size={18} />, count: 3 },
              { id: 'rdv', label: 'Rendez-vous', icon: <Calendar size={18} /> },
            ]
          },
          {
            section: 'Compte',
            items: [
              { id: 'parametres', label: 'Paramètres', icon: <Settings size={18} /> },
            ]
          }
        ];
      case 'comptable':
        return [
          {
            section: 'Général',
            items: [
              { id: 'dashboard', label: 'Tableau de bord', icon: <LayoutDashboard size={18} /> },
              { id: 'dossiers', label: 'Dossiers attribués', icon: <Folder size={18} />, count: 14 },
            ]
          },
          {
            section: 'Traitement',
            items: [
              { id: 'documents', label: 'Documents', icon: <FileText size={18} />, count: 18 },
              { id: 'comptabilite', label: 'Comptabilité', icon: <BookOpen size={18} /> },
              { id: 'facturation', label: 'Facturation & fiscalité', icon: <FileCheck size={18} />, count: 7 },
              { id: 'echeances', label: 'Échéances', icon: <Clock size={18} />, count: 5 },
            ]
          },
          {
            section: 'Collaboration',
            items: [
              { id: 'taches', label: 'Tâches', icon: <FileCheck size={18} />, count: 6 },
              { id: 'messagerie', label: 'Messagerie', icon: <MessageSquare size={18} />, count: 3 },
            ]
          }
        ];
      case 'admin':
      default:
        return [
          {
            section: 'Pilotage',
            items: [
              { id: 'dashboard', label: 'Tableau de bord', icon: <LayoutDashboard size={18} /> },
              { id: 'rapports', label: 'Rapports', icon: <TrendingUp size={18} /> },
            ]
          },
          {
            section: 'Cabinet',
            items: [
              { id: 'clients', label: 'Clients', icon: <Users size={18} />, count: 152 },
              { id: 'utilisateurs', label: 'Collaborateurs', icon: <Users size={18} />, count: 24 },
              { id: 'dossiers', label: 'Dossiers', icon: <Folder size={18} />, count: 87 },
            ]
          },
          {
            section: 'Opérations',
            items: [
              { id: 'documents', label: 'Documents', icon: <FileText size={18} /> },
              { id: 'factures', label: 'Facturation', icon: <FileCheck size={18} /> },
              { id: 'fiscalite', label: 'Fiscalité', icon: <BookOpen size={18} /> },
            ]
          },
          {
            section: 'Gouvernance',
            items: [
              { id: 'securite', label: 'Sécurité & audit', icon: <ShieldAlert size={18} />, count: 2 },
              { id: 'parametres', label: 'Paramètres', icon: <Settings size={18} /> },
            ]
          }
        ];
    }
  };

  const getRoleLabel = () => {
    switch (demoRole) {
      case 'client':
        return 'Espace Client';
      case 'comptable':
        return 'Espace Collaborateur';
      case 'admin':
      default:
        return 'Espace Administrateur';
    }
  };

  const getAvatarInitials = () => {
    switch (demoRole) {
      case 'client':
        return 'AB';
      case 'comptable':
        return 'SJ';
      case 'admin':
      default:
        return 'KB';
    }
  };

  const getAvatarName = () => {
    switch (demoRole) {
      case 'client':
        return 'Ahmed Ben Ali';
      case 'comptable':
        return 'Sarah Jlassi';
      case 'admin':
      default:
        return 'Karim Ben Said';
    }
  };

  const getAvatarSubtitle = () => {
    switch (demoRole) {
      case 'client':
        return 'Client — Société Générale SARL';
      case 'comptable':
        return 'Comptable senior';
      case 'admin':
      default:
        return 'Administrateur';
    }
  };

  const getAvatarBg = () => {
    switch (demoRole) {
      case 'client':
        return '#3b7ddb';
      case 'comptable':
        return '#f4841f';
      case 'admin':
      default:
        return '#3d2170';
    }
  };

  return (
    <div className="layout">
      {/* Mobile Header */}
      <div className="mobile-header">
        <div className="logo-text">CEO.IT</div>
        <button className="icon-btn" onClick={() => setMobileMenuOpen(!mobileMenuOpen)}>
          {mobileMenuOpen ? <X size={24} /> : <Menu size={24} />}
        </button>
      </div>

      {/* Sidebar */}
      <aside className={`sidebar ${mobileMenuOpen ? 'open' : ''}`}>
        <div className="brand" style={{ padding: '22px 20px 16px', display: 'flex', alignItems: 'center', gap: '10px' }}>
          <div className="brand-mark" style={{
            width: '34px', height: '34px', borderRadius: '9px',
            background: 'linear-gradient(135deg, #3b7ddb, #f4841f 45%, #f0b429 75%, #3d2170)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontFamily: 'Sora', fontWeight: 800, color: '#fff', fontSize: '15px'
          }}>
            CI
          </div>
          <div>
            <div className="brand-name" style={{ fontFamily: 'Sora', fontWeight: 700, fontSize: '17px', color: '#0f172a', lineHeight: 1 }}>
              CEO.IT
            </div>
            <div className="brand-tag" style={{ fontSize: '10px', color: '#64748b', letterSpacing: '.06em', textTransform: 'uppercase', marginTop: '3px' }}>
              {getRoleLabel()}
            </div>
          </div>
        </div>

        <div className="brand-bar">
          <span></span>
          <span></span>
          <span></span>
          <span></span>
        </div>
        
        <nav className="sidebar-nav" style={{ flex: 1, overflowY: 'auto' }}>
          {getNavConfig().map((section) => (
            <div key={section.section}>
              <div className="sidebar-section-label">{section.section}</div>
              {section.items.map((item) => (
                <button 
                  key={item.id} 
                  className={`nav-item full-width ${activeTab === item.id ? 'active' : ''}`}
                  onClick={() => handleTabClick(item.id)}
                  style={{ 
                    border: 'none', 
                    background: 'transparent', 
                    textAlign: 'left', 
                    cursor: 'pointer',
                    display: 'flex',
                    alignItems: 'center',
                    gap: '0.8rem'
                  }}
                >
                  {item.icon}
                  <span>{item.label}</span>
                  {item.count && <span className="count" style={{ marginLeft: 'auto', background: '#f1f5f9', color: '#475569', padding: '2px 8px', borderRadius: '20px', fontSize: '0.75rem', fontFamily: 'IBM Plex Mono', fontWeight: 600 }}>{item.count}</span>}
                </button>
              ))}
            </div>
          ))}
        </nav>

        <div className="sidebar-foot" style={{ padding: '14px 20px', borderTop: '1px solid #f1f5f9', fontSize: '11px', color: '#94a3b8' }}>
          CEO-IT v1.0 — Démo interactive
        </div>
      </aside>

      {/* Main Content */}
      <main className="main-content">
        <header className="topbar">
          {/* Custom Search Box */}
          <div className="search-box">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style={{ width: '15px', height: '15px' }}><circle cx="11" cy="11" r="7"/><path d="M21 21l-4.3-4.3"/></svg>
            <input type="text" placeholder="Rechercher un dossier, un document…" />
          </div>

          {/* Interactive Role Switcher in Topbar */}
          <div className="role-switch">
            <button 
              className={demoRole === 'client' ? 'active' : ''} 
              onClick={() => {
                setDemoRole('client');
                navigate('/');
              }}
              data-role="client"
            >
              <span className="dot"></span>Client
            </button>
            <button 
              className={demoRole === 'comptable' ? 'active' : ''} 
              onClick={() => {
                setDemoRole('comptable');
                navigate('/');
              }}
              data-role="comptable"
            >
              <span className="dot"></span>Collaborateur
            </button>
            <button 
              className={demoRole === 'admin' ? 'active' : ''} 
              onClick={() => {
                setDemoRole('admin');
                navigate('/');
              }}
              data-role="admin"
            >
              <span className="dot"></span>Administrateur
            </button>
          </div>

          {/* User Controls */}
          <div className="user-controls" style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
            <div className="profile" style={{ display: 'flex', alignItems: 'center', gap: '9px' }}>
              <div className="avatar" style={{ 
                width: '34px', height: '34px', borderRadius: '50%', 
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                fontFamily: 'Sora', fontWeight: 700, fontSize: '12.5px', color: '#fff',
                background: getAvatarBg() 
              }}>
                {getAvatarInitials()}
              </div>
              <div className="desktop-only">
                <div className="profile-name" style={{ fontSize: '12.5px', fontWeight: 600, lineHeight: 1.2 }}>{getAvatarName()}</div>
                <div className="profile-role" style={{ fontSize: '11px', color: '#94a3b8' }}>{getAvatarSubtitle()}</div>
              </div>
            </div>
            <button onClick={handleLogout} className="icon-btn logout-btn" title="Déconnexion" style={{ border: '1px solid rgba(255,255,255,0.1)', padding: '0.4rem', borderRadius: '8px' }}>
              <LogOut size={18} />
            </button>
          </div>
        </header>
        
        <div className="page-container" style={{ flex: 1, overflowY: 'auto' }}>
          <Outlet />
        </div>
      </main>
    </div>
  );
};

export default Layout;
