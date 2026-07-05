import { useContext, useState } from 'react';
import { Outlet, Link, useNavigate, useLocation } from 'react-router-dom';
import { AuthContext } from '../context/AuthContext';
import { LayoutDashboard, Camera, FileText, Settings, LogOut, Menu, X } from 'lucide-react';

const Layout = () => {
  const { user, logout } = useContext(AuthContext);
  const navigate = useNavigate();
  const location = useLocation();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  const navItems = [
    { path: '/', label: 'Tableau de bord', icon: <LayoutDashboard size={20} /> },
    { path: '/capture', label: 'Capture OCR', icon: <Camera size={20} /> },
    { path: '/factures', label: 'Mes Factures', icon: <FileText size={20} /> },
  ];

  if (user?.role === 'admin') {
    navItems.push({ path: '/admin', label: 'Administration', icon: <Settings size={20} /> });
  }

  return (
    <div className="layout">
      {/* Mobile Header */}
      <div className="mobile-header">
        <div className="logo-text">Secure Invoice AI</div>
        <button className="icon-btn" onClick={() => setMobileMenuOpen(!mobileMenuOpen)}>
          {mobileMenuOpen ? <X size={24} /> : <Menu size={24} />}
        </button>
      </div>

      {/* Sidebar */}
      <aside className={`sidebar ${mobileMenuOpen ? 'open' : ''}`}>
        <div className="sidebar-header desktop-only">
          <div className="logo-text" style={{ fontSize: '1.2rem', marginBottom: '2rem', padding: '0 1rem' }}>
            Secure Invoice AI
          </div>
        </div>
        
        <nav className="sidebar-nav">
          {navItems.map((item) => (
            <Link 
              key={item.path} 
              to={item.path} 
              className={`nav-item ${location.pathname === item.path ? 'active' : ''}`}
              onClick={() => setMobileMenuOpen(false)}
            >
              {item.icon}
              <span>{item.label}</span>
            </Link>
          ))}
        </nav>
      </aside>

      {/* Main Content */}
      <main className="main-content">
        <header className="topbar">
          <div className="page-title">
            {navItems.find(item => item.path === location.pathname)?.label || 'Page'}
          </div>
          <div className="user-controls">
            <span className={`badge badge-${user?.role}`}>{user?.role}</span>
            <span className="user-name">{user?.nom}</span>
            <button onClick={handleLogout} className="icon-btn logout-btn" title="Déconnexion">
              <LogOut size={20} />
            </button>
          </div>
        </header>
        
        <div className="page-container">
          <Outlet />
        </div>
      </main>
    </div>
  );
};

export default Layout;
