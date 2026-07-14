import React, { useState, useContext } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../api';
import { AuthContext } from '../context/AuthContext';
import {
  ShieldCheck,
  Fingerprint,
  ArrowRight,
  Mail,
  Lock,
  Eye,
  EyeOff,
  KeyRound,
} from 'lucide-react';

const LoginPage = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [mode, setMode] = useState<'signin' | 'signup'>('signin');
  const { login } = useContext(AuthContext);
  const navigate = useNavigate();

  const handleLogin = async (eEmail: string, ePass: string) => {
    setError('');
    setLoading(true);
    try {
      const formData = new URLSearchParams();
      formData.append('username', eEmail);
      formData.append('password', ePass);

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

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    handleLogin(email, password);
  };

  const handleDemoAccess = (role: 'client' | 'comptable' | 'admin') => {
    const creds = {
      client: { email: 'client@demo.com', pass: 'client123' },
      comptable: { email: 'comptable@demo.com', pass: 'comptable123' },
      admin: { email: 'admin@demo.com', pass: 'admin123' },
    }[role];
    
    setEmail(creds.email);
    setPassword(creds.pass);
    handleLogin(creds.email, creds.pass);
  };

  return (
    <div className="relative min-h-screen bg-background grain-bg overflow-hidden flex flex-col justify-center">
      {/* Ambient orbs */}
      <div className="pointer-events-none absolute -top-40 -left-20 h-[420px] w-[420px] rounded-full bg-[oklch(0.86_0.18_128)] opacity-40 blur-3xl" />
      <div className="pointer-events-none absolute -bottom-40 -right-20 h-[420px] w-[420px] rounded-full bg-[oklch(0.28_0.06_155)] opacity-25 blur-3xl" />

      <div className="mx-auto max-w-[480px] w-full px-5 py-6 relative">
        {/* Top brand header */}
        <header className="flex items-center justify-between animate-rise">
          <div className="flex items-center gap-2">
            <div className="relative h-9 w-9 rounded-xl bg-primary grid place-items-center">
              <div className="h-3.5 w-3.5 rounded-[4px] bg-[oklch(0.86_0.18_128)]" />
              <div className="absolute -bottom-0.5 -right-0.5 h-3 w-3 rounded-full bg-background grid place-items-center">
                <ShieldCheck className="h-2 w-2 text-primary" strokeWidth={3} />
              </div>
            </div>
            <div className="leading-tight text-foreground">
              <div className="font-display text-lg italic">Ledger</div>
              <div className="text-[9px] uppercase tracking-[0.18em] text-muted-foreground -mt-0.5">Secure · Invoice · AI</div>
            </div>
          </div>
        </header>

        {/* Hero copy */}
        <section className="mt-10 animate-rise" style={{ animationDelay: '60ms' }}>
          <div className="inline-flex items-center gap-2 rounded-full border border-border bg-card/60 backdrop-blur px-3 py-1 text-[10px] uppercase tracking-[0.2em] text-muted-foreground">
            <span className="h-1.5 w-1.5 rounded-full bg-[oklch(0.55_0.6_150)] animate-pulse-dot" />
            {mode === 'signin' ? 'Welcome back' : 'Create account'}
          </div>
          <h1 className="mt-4 font-display text-[44px] leading-[1.02] tracking-tight">
            Sign in to your
            <br />
            <span className="italic">secure ledger.</span>
          </h1>
          <p className="mt-3 text-sm text-muted-foreground max-w-[85%]">
            Cryptographic receipts, hardware-bound sessions, zero-knowledge password proofs.
          </p>
        </section>

        {/* Error Alert */}
        {error && (
          <div className="mt-4 p-3 rounded-2xl bg-destructive/10 border border-destructive/20 text-destructive text-xs animate-rise">
            {error}
          </div>
        )}

        {/* Card */}
        <section className="mt-6 animate-rise" style={{ animationDelay: '140ms' }}>
          <div className="relative rounded-3xl border border-border bg-card/80 backdrop-blur-xl p-6 shadow-[0_30px_80px_-30px_oklch(0.22_0.03_155/0.35)] overflow-hidden">
            <div className="absolute inset-x-0 top-0 h-px animate-shimmer" />

            {/* Mode toggle */}
            <div className="flex items-center gap-1 rounded-full border border-border p-1 bg-background/60">
              {(['signin', 'signup'] as const).map((m) => (
                <button
                  key={m}
                  type="button"
                  onClick={() => {
                    if (m === 'signup') {
                      alert("L'inscription est désactivée pour cette version de démonstration.");
                    } else {
                      setMode(m);
                    }
                  }}
                  className={`flex-1 rounded-full px-3 py-1.5 text-xs font-medium transition ${
                    mode === m
                      ? 'bg-primary text-primary-foreground'
                      : 'text-muted-foreground hover:text-foreground'
                  }`}
                >
                  {m === 'signin' ? 'Sign in' : 'Create account'}
                </button>
              ))}
            </div>

            {/* Social Logins styled as Demo Access Buttons */}
            <div className="mt-5 grid grid-cols-1 gap-2">
              <button 
                type="button"
                onClick={() => handleDemoAccess('client')}
                className="group flex items-center justify-between rounded-2xl border border-border bg-background/60 px-4 py-3 hover:border-foreground/30 transition text-left"
              >
                <div className="flex items-center gap-3">
                  <div className="h-9 w-9 rounded-xl bg-[oklch(0.86_0.18_128)] grid place-items-center">
                    <Fingerprint className="h-4 w-4 text-[oklch(0.22_0.03_155)]" strokeWidth={2.25} />
                  </div>
                  <div>
                    <div className="text-sm font-medium">Continue as Client</div>
                    <div className="text-[11px] text-muted-foreground">Submit invoices & check status</div>
                  </div>
                </div>
                <ArrowRight className="h-4 w-4 text-muted-foreground group-hover:translate-x-0.5 transition" />
              </button>
              
              <div className="grid grid-cols-2 gap-2">
                <button 
                  type="button"
                  onClick={() => handleDemoAccess('comptable')}
                  className="rounded-2xl border border-border bg-background/60 px-3 py-2.5 text-xs font-medium hover:bg-background transition inline-flex items-center justify-center gap-2"
                >
                  <KeyRound className="h-3.5 w-3.5 text-primary" />
                  Comptable
                </button>
                <button 
                  type="button"
                  onClick={() => handleDemoAccess('admin')}
                  className="rounded-2xl border border-border bg-background/60 px-3 py-2.5 text-xs font-medium hover:bg-background transition inline-flex items-center justify-center gap-2"
                >
                  <ShieldCheck className="h-3.5 w-3.5 text-primary" />
                  Admin
                </button>
              </div>
            </div>

            {/* Divider */}
            <div className="my-5 flex items-center gap-3">
              <div className="h-px flex-1 bg-border" />
              <span className="text-[10px] uppercase tracking-[0.22em] text-muted-foreground">or with credentials</span>
              <div className="h-px flex-1 bg-border" />
            </div>

            {/* Form */}
            <form onSubmit={handleSubmit} className="space-y-3">
              <div>
                <span className="text-[10px] uppercase tracking-[0.2em] text-muted-foreground">Email</span>
                <div className="mt-1.5 relative">
                  <Mail className="absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                  <input
                    required
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="you@company.com"
                    className="w-full rounded-2xl border border-border bg-background/60 pl-10 pr-4 py-3 text-sm focus:outline-none focus:border-foreground/40 transition"
                  />
                </div>
              </div>
              <div>
                <div className="flex items-center justify-between">
                  <span className="text-[10px] uppercase tracking-[0.2em] text-muted-foreground">Password</span>
                </div>
                <div className="mt-1.5 relative">
                  <Lock className="absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                  <input
                    required
                    type={showPassword ? 'text' : 'password'}
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    placeholder="••••••••••"
                    className="w-full rounded-2xl border border-border bg-background/60 pl-10 pr-11 py-3 text-sm focus:outline-none focus:border-foreground/40 transition font-mono-tight"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword((s) => !s)}
                    className="absolute right-3 top-1/2 -translate-y-1/2 h-7 w-7 rounded-full grid place-items-center hover:bg-secondary/40"
                  >
                    {showPassword ? <EyeOff className="h-3.5 w-3.5" /> : <Eye className="h-3.5 w-3.5" />}
                  </button>
                </div>
              </div>

              <button
                type="submit"
                disabled={loading}
                className="mt-2 group w-full inline-flex items-center justify-center gap-2 rounded-2xl bg-primary text-primary-foreground py-3.5 text-sm font-medium hover:opacity-95 transition disabled:opacity-50"
              >
                {loading ? 'Signing in...' : 'Continue'}
                <ArrowRight className="h-4 w-4 group-hover:translate-x-0.5 transition" />
              </button>
            </form>
          </div>
        </section>

        {/* Trust row */}
        <section className="mt-6 grid grid-cols-3 gap-2 animate-rise" style={{ animationDelay: '220ms' }}>
          {[
            { k: 'SOC 2', v: 'Type II' },
            { k: 'ISO', v: '27001' },
            { k: 'E2E', v: 'Signed' },
          ].map((t) => (
            <div key={t.k} className="rounded-2xl border border-border bg-card/60 backdrop-blur px-3 py-2.5 text-center">
              <div className="text-[9px] uppercase tracking-[0.2em] text-muted-foreground">{t.k}</div>
              <div className="mt-0.5 font-mono-tight text-xs">{t.v}</div>
            </div>
          ))}
        </section>

        <p className="mt-6 text-center text-[10px] uppercase tracking-[0.22em] text-muted-foreground font-mono-tight">
          Ledger · v2.4.1
        </p>
      </div>
    </div>
  );
};

export default LoginPage;
