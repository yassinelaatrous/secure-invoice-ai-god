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
    <div className="login-container">
      <div className="login-card glass-card">
        
        {/* Brand header */}
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '8px', marginBottom: '2rem' }}>
          <Logo size={48} />
          <h1 style={{ fontFamily: 'Outfit', fontWeight: 800, fontSize: '1.8rem', color: '#fff', letterSpacing: '-0.03em' }}>CEO.IT</h1>
        </div>

        {/* Sign In / Join Tabs Header matching Photo 2 */}
        <div style={{ display: 'flex', gap: '24px', marginBottom: '2rem', borderBottom: '1px solid rgba(255,255,255,0.06)', paddingBottom: '0.75rem' }}>
          <div style={{ position: 'relative', cursor: 'pointer' }}>
            <span style={{ fontSize: '1.4rem', fontWeight: 700, color: '#fff', fontFamily: 'Outfit' }}>Sign In</span>
            <div style={{ position: 'absolute', bottom: '-13px', left: 0, right: 0, height: '3px', background: 'linear-gradient(90deg, var(--glow-orange), var(--primary))', borderRadius: '2px' }}></div>
          </div>
          <div style={{ cursor: 'pointer', opacity: 0.3 }}>
            <span style={{ fontSize: '1.4rem', fontWeight: 600, color: '#fff', fontFamily: 'Outfit' }}>Join</span>
          </div>
        </div>

        {error && <div className="alert error">{error}</div>}

        <form onSubmit={handleSubmit} className="login-form">
          <div className="form-group">
            <label>Email</label>
            <div className="input-with-icon">
              <Mail size={18} className="input-icon" />
              <input 
                type="email" 
                value={email} 
                onChange={e => setEmail(e.target.value)} 
                placeholder="hey@vino.costa"
                required 
              />
            </div>
          </div>
          
          <div className="form-group">
            <label>Password</label>
            <div className="input-with-icon">
              <Lock size={18} className="input-icon" />
              <input 
                type={showPassword ? "text" : "password"} 
                value={password} 
                onChange={e => setPassword(e.target.value)} 
                placeholder="At least 12 symbols..."
                required 
              />
              <button 
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                style={{
                  position: 'absolute', right: '12px', top: '50%', transform: 'translateY(-50%)',
                  background: 'none', border: 'none', color: 'rgba(255,255,255,0.4)', cursor: 'pointer',
                  display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '4px'
                }}
              >
                {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
              </button>
            </div>
          </div>

          <button type="submit" className="btn btn-primary full-width" disabled={loading} style={{ marginTop: '1rem' }}>
            {loading ? 'Connexion en cours...' : 'Se connecter'}
          </button>
        </form>

        {/* Social Logins matching Photo 2 */}
        <div style={{ marginTop: '2rem', display: 'flex', justifyContent: 'center', gap: '12px' }}>
          {[
            {
              name: 'Google',
              color: 'rgba(255, 255, 255, 0.03)',
              icon: (
                <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor">
                  <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/>
                  <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/>
                  <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z" fill="#FBBC05"/>
                  <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z" fill="#EA4335"/>
                </svg>
              )
            },
            {
              name: 'Apple',
              color: 'rgba(255, 255, 255, 0.03)',
              icon: (
                <svg viewBox="0 0 24 24" width="18" height="18" fill="white">
                  <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M15.97 4.17c.66-.81 1.11-1.93.99-3.06-1 .04-2.21.67-2.93 1.49-.62.69-1.16 1.84-1.01 2.96 1.12.09 2.27-.57 2.95-1.39z"/>
                </svg>
              )
            },
            {
              name: 'X',
              color: 'rgba(255, 255, 255, 0.03)',
              icon: (
                <svg viewBox="0 0 24 24" width="16" height="16" fill="white">
                  <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/>
                </svg>
              )
            },
            {
              name: 'Discord',
              color: 'rgba(255, 255, 255, 0.03)',
              icon: (
                <svg viewBox="0 0 127.14 96.36" width="18" height="18" fill="white">
                  <path d="M107.7,8.07A105.15,105.15,0,0,0,77.26,0a77.19,77.19,0,0,0-3.3,6.83A96.67,96.67,0,0,0,53.22,6.83,77.19,77.19,0,0,0,49.88,0,105.15,105.15,0,0,0,19.44,8.07C3.66,31.58-1.86,54.65,1,77.53A105.73,105.73,0,0,0,32,96.36a77.7,77.7,0,0,0,6.63-10.85,68.43,68.43,0,0,1-10.5-5c.8-.59,1.57-1.22,2.31-1.87a75.7,75.7,0,0,0,73.41,0c.74.65,1.51,1.28,2.31,1.87a68.43,68.43,0,0,1-10.5,5,77.7,77.7,0,0,0,6.63,10.85,105.73,105.73,0,0,0,31.42-18.83C129.24,48.51,123.36,25.68,107.7,8.07ZM42.45,65.69C36.18,65.69,31,60,31,53S36.18,40.36,42.45,40.36,53.83,46,53.83,53,48.72,65.69,42.45,65.69Zm42.24,0C78.41,65.69,73.24,60,73.24,53S78.41,40.36,84.69,40.36,96.07,46,96.07,53,91,65.69,84.69,65.69Z"/>
                </svg>
              )
            }
          ].map((soc, i) => (
            <button 
              key={i} 
              type="button"
              title={soc.name}
              style={{
                width: '56px', height: '44px', borderRadius: '12px', border: '1px solid rgba(255,255,255,0.06)',
                background: soc.color, display: 'flex', alignItems: 'center', justifyContent: 'center',
                cursor: 'pointer', transition: 'all 0.2s', boxShadow: '0 4px 12px rgba(0,0,0,0.1)'
              }}
              onMouseEnter={e => {
                e.currentTarget.style.background = 'rgba(255,255,255,0.08)';
                e.currentTarget.style.borderColor = 'rgba(255,255,255,0.15)';
              }}
              onMouseLeave={e => {
                e.currentTarget.style.background = soc.color;
                e.currentTarget.style.borderColor = 'rgba(255,255,255,0.06)';
              }}
            >
              {soc.icon}
            </button>
          ))}
        </div>

        <div className="demo-credentials">
          <p><strong>Comptes de démo :</strong></p>
          <ul>
            <li>client@demo.com / client123</li>
            <li>comptable@demo.com / comptable123</li>
            <li>admin@demo.com / admin123</li>
          </ul>
        </div>
      </div>
    </div>
  );
};

export default LoginPage;
