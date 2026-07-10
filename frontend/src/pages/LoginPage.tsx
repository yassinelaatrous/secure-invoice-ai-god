import React, { useState, useContext } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../api';
import { AuthContext } from '../context/AuthContext';
import { Lock, Mail, Eye, EyeOff } from 'lucide-react';
import Logo from '../components/Logo';

const LoginPage = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const { login } = useContext(AuthContext);
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      const formData = new URLSearchParams();
      formData.append('username', email);
      formData.append('password', password);

      const res = await api.post('/auth/login', formData, {
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
      });

      login(res.data.access_token, res.data.user);
      navigate('/');
    } catch (err: any) {
      setError(err.response?.data?.detail || 'Erreur de connexion');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="login-split-container">
      {/* LEFT SIDE: Login Form */}
      <div className="login-left-side">
        {/* Brand Header */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <Logo size={36} />
          <span style={{ fontFamily: 'Outfit', fontWeight: 800, fontSize: '1.4rem', color: 'var(--text-primary)', letterSpacing: '-0.02em' }}>CEO.IT</span>
        </div>

        {/* Form Container */}
        <div style={{ maxWidth: '400px', width: '100%', margin: 'auto 0' }}>
          <div style={{ marginBottom: '2rem' }}>
            <h1 style={{ fontFamily: 'Outfit', fontWeight: 800, fontSize: '2.2rem', color: 'var(--text-primary)', marginBottom: '0.5rem', letterSpacing: '-0.03em' }}>Welcome Back</h1>
            <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem' }}>Welcome Back, Please enter Your details</p>
          </div>

          {/* Toggle pill */}
          <div className="login-pill-toggle" style={{ marginBottom: '2rem' }}>
            <button type="button" className="login-pill-btn active">Sign In</button>
            <button type="button" className="login-pill-btn" onClick={() => alert("L'inscription est désactivée pour cette version de démonstration.")}>Signup</button>
          </div>

          {error && <div className="alert error">{error}</div>}

          <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
            <div className="form-group" style={{ marginBottom: 0 }}>
              <label>Email Address</label>
              <div className="input-with-icon">
                <Mail size={18} className="input-icon" />
                <input 
                  type="email" 
                  value={email} 
                  onChange={e => setEmail(e.target.value)} 
                  placeholder="enter your email..."
                  required 
                  style={{ background: '#ffffff', borderRadius: '12px', border: '1px solid #dcdce2', padding: '0.8rem 1.25rem 0.8rem 2.8rem' }}
                />
              </div>
            </div>

            <div className="form-group" style={{ marginBottom: 0 }}>
              <label>Password</label>
              <div className="input-with-icon">
                <Lock size={18} className="input-icon" />
                <input 
                  type={showPassword ? "text" : "password"} 
                  value={password} 
                  onChange={e => setPassword(e.target.value)} 
                  placeholder="••••••••••••"
                  required 
                  style={{ background: '#ffffff', borderRadius: '12px', border: '1px solid #dcdce2', padding: '0.8rem 1.25rem 0.8rem 2.8rem' }}
                />
                <button 
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  style={{
                    position: 'absolute', right: '12px', top: '50%', transform: 'translateY(-50%)',
                    background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer',
                    display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '4px'
                  }}
                >
                  {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                </button>
              </div>
            </div>

            <button type="submit" className="btn btn-primary full-width" disabled={loading} style={{ marginTop: '0.5rem', background: '#2563eb', padding: '0.8rem 1.4rem' }}>
              {loading ? 'Connexion en cours...' : 'Continue'}
            </button>
          </form>

          {/* Social Logins */}
          <div style={{ margin: '2rem 0', display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
              <div style={{ flex: 1, height: '1px', background: '#e5e5eb' }}></div>
              <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)', fontWeight: 500 }}>Or Continue With</span>
              <div style={{ flex: 1, height: '1px', background: '#e5e5eb' }}></div>
            </div>

            <div style={{ display: 'flex', justifyContent: 'center', gap: '16px' }}>
              {[
                {
                  name: 'Google',
                  icon: (
                    <svg viewBox="0 0 24 24" width="20" height="20">
                      <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/>
                      <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/>
                      <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z" fill="#FBBC05"/>
                      <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z" fill="#EA4335"/>
                    </svg>
                  )
                },
                {
                  name: 'Apple',
                  icon: (
                    <svg viewBox="0 0 24 24" width="20" height="20" fill="#12100f">
                      <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M15.97 4.17c.66-.81 1.11-1.93.99-3.06-1 .04-2.21.67-2.93 1.49-.62.69-1.16 1.84-1.01 2.96 1.12.09 2.27-.57 2.95-1.39z"/>
                    </svg>
                  )
                },
                {
                  name: 'Facebook',
                  icon: (
                    <svg viewBox="0 0 24 24" width="20" height="20" fill="#1877F2">
                      <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47H3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/>
                    </svg>
                  )
                }
              ].map((soc, i) => (
                <button 
                  key={i} 
                  type="button"
                  title={soc.name}
                  style={{
                    width: '50px', height: '50px', borderRadius: '50%', border: '1px solid #dcdce2',
                    background: '#ffffff', display: 'flex', alignItems: 'center', justifyContent: 'center',
                    cursor: 'pointer', transition: 'all 0.2s', boxShadow: '0 2px 6px rgba(0,0,0,0.03)'
                  }}
                  onMouseEnter={e => {
                    e.currentTarget.style.background = '#f9fafb';
                    e.currentTarget.style.borderColor = '#c8c8cf';
                  }}
                  onMouseLeave={e => {
                    e.currentTarget.style.background = '#ffffff';
                    e.currentTarget.style.borderColor = '#dcdce2';
                  }}
                >
                  {soc.icon}
                </button>
              ))}
            </div>
          </div>

          {/* Demo credentials */}
          <div className="demo-credentials" style={{ padding: '1rem', background: '#f9fafb', borderRadius: '12px', border: '1px solid #e5e5eb', fontSize: '0.8rem', color: 'var(--text-secondary)' }}>
            <p style={{ fontWeight: 700, marginBottom: '6px', color: 'var(--text-primary)' }}>Comptes de démonstration :</p>
            <ul style={{ listStyleType: 'none', display: 'flex', flexDirection: 'column', gap: '4px', paddingLeft: 0 }}>
              <li><strong>Client :</strong> client@demo.com / client123</li>
              <li><strong>Comptable :</strong> comptable@demo.com / comptable123</li>
              <li><strong>Admin :</strong> admin@demo.com / admin123</li>
            </ul>
          </div>
        </div>

        {/* Footer info text */}
        <div style={{ fontSize: '0.75rem', color: 'var(--text-secondary)', textAlign: 'center', marginTop: '2rem', lineHeight: 1.4 }}>
          Join the millions of smart businesses who trust us to manage their invoices, track audit compliance, and detect financial fraud.
        </div>
      </div>

      {/* RIGHT SIDE: 3D Illustration / Brand display */}
      <div className="login-right-side">
        {/* Particle Rain streaks */}
        <div className="login-rain-particles">
          {[
            { left: '15%', top: '-20px', delay: '0s', duration: '3s' },
            { left: '35%', top: '-50px', delay: '1s', duration: '4s' },
            { left: '55%', top: '-10px', delay: '0.5s', duration: '2.5s' },
            { left: '75%', top: '-60px', delay: '2s', duration: '3.5s' },
            { left: '90%', top: '-30px', delay: '1.5s', duration: '4.5s' },
          ].map((st, i) => (
            <div 
              key={i} 
              className="rain-streak" 
              style={{ 
                left: st.left, 
                top: st.top, 
                animationDelay: st.delay, 
                animationDuration: st.duration 
              }}
            ></div>
          ))}
        </div>

        {/* Floating 3D Safe illustration */}
        <div className="floating-safe-container">
          <img 
            src="/login_safe_box.png" 
            alt="Secure Invoice Safe" 
            className="floating-safe-image" 
          />
          <div className="floating-safe-shadow"></div>
        </div>

        <div style={{ marginTop: '3rem', textAlign: 'center', color: '#ffffff', padding: '0 2rem', zIndex: 2 }}>
          <h2 style={{ color: '#ffffff', fontSize: '1.8rem', fontWeight: 800, marginBottom: '0.5rem', fontFamily: 'Outfit' }}>Sécurité Inégalée</h2>
          <p style={{ color: 'rgba(255,255,255,0.8)', fontSize: '0.95rem', maxWidth: '380px', margin: '0 auto', lineHeight: 1.5 }}>
            Vos données financières sont chiffrées de bout en bout et auditées en temps réel par notre intelligence artificielle.
          </p>
        </div>
      </div>
    </div>
  );
};

export default LoginPage;
