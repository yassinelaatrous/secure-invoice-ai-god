import { useState, useEffect } from 'react';
import { useSearchParams } from 'react-router-dom';
import { Camera, CheckCircle, UploadCloud, AlertCircle, RefreshCw } from 'lucide-react';
import axios from 'axios';
import Logo from '../components/Logo';

const MobileUploadPage = () => {
  const [searchParams] = useSearchParams();
  const sessionId = searchParams.get('session');
  
  const [file, setFile] = useState<File | null>(null);
  const [previewUrl, setPreviewUrl] = useState<string | null>(null);
  const [status, setStatus] = useState<'idle' | 'loading' | 'success' | 'error'>('idle');
  const [errorMessage, setErrorMessage] = useState<string>('');

  useEffect(() => {
    document.title = "CEO.IT — Mobile Upload";
  }, []);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      const selectedFile = e.target.files[0];
      setFile(selectedFile);
      setPreviewUrl(URL.createObjectURL(selectedFile));
      setStatus('idle');
    }
  };

  const handleUpload = async () => {
    if (!file || !sessionId) {
      setErrorMessage("Fichier ou ID de session manquant.");
      setStatus('error');
      return;
    }

    setStatus('loading');
    const formData = new FormData();
    formData.append('file', file);

    try {
      const backendUrl = window.location.origin.includes('localhost') 
        ? 'http://localhost:8000' 
        : window.location.origin.replace(':3000', ':8000'); 

      await axios.post(`${backendUrl}/api/upload/mobile/${sessionId}`, formData, {
        headers: {
          'Content-Type': 'multipart/form-data'
        }
      });
      setStatus('success');
    } catch (err: any) {
      console.error(err);
      setErrorMessage(err.response?.data?.detail || "Erreur lors de la transmission du document.");
      setStatus('error');
    }
  };

  const resetPage = () => {
    setFile(null);
    setPreviewUrl(null);
    setStatus('idle');
  };

  if (!sessionId) {
    return (
      <div className="layout" style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', background: '#12100f', color: '#fff', padding: '20px', fontFamily: 'var(--font-family)' }}>
        <div className="card-dark text-center" style={{ padding: '2.5rem 2rem', maxWidth: '400px', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '1rem' }}>
          <AlertCircle size={48} className="text-error" style={{ margin: '0 auto' }} />
          <h2 style={{ fontSize: '1.4rem', fontWeight: 800 }}>Session manquante</h2>
          <p style={{ color: 'var(--text-secondary)', fontSize: '14px', lineHeight: 1.5 }}>
            Cette page doit être ouverte en scannant le QR code affiché sur l'écran de votre ordinateur.
          </p>
        </div>
      </div>
    );
  }

  return (
    <div style={{ minHeight: '100vh', background: '#12100f', color: '#fff', fontFamily: 'var(--font-family)', padding: '40px 15px' }}>
      <div style={{ maxWidth: '480px', margin: '0 auto' }}>
        
        {/* Brand header */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '30px', justifyContent: 'center' }}>
          <Logo size={36} />
          <div style={{ fontFamily: 'var(--font-heading)', fontWeight: 800, fontSize: '20px', letterSpacing: '-0.02em' }}>CEO.IT Mobile</div>
        </div>

        {status === 'success' ? (
          <div className="card-dark text-center" style={{ padding: '2.5rem 1.5rem', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '1rem' }}>
            <div style={{ display: 'inline-flex', alignItems: 'center', justifyContent: 'center', width: '64px', height: '64px', borderRadius: '50%', background: 'rgba(187, 251, 149, 0.1)', color: 'var(--primary)', marginBottom: '0.5rem' }}>
              <CheckCircle size={36} />
            </div>
            <h2 style={{ fontSize: '1.4rem', fontWeight: 800 }}>Document Envoyé !</h2>
            <p style={{ color: 'var(--text-secondary)', fontSize: '14px', lineHeight: 1.5, marginBottom: '1rem' }}>
              L'analyse OCR IA est lancée. Les données extraites vont s'afficher automatiquement sur l'écran de votre ordinateur.
            </p>
            <button className="btn btn-outline full-width" onClick={resetPage} style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px' }}>
              <RefreshCw size={16} /> Envoyer un autre document
            </button>
          </div>
        ) : (
          <div className="card-dark" style={{ padding: '24px' }}>
            <div style={{ marginBottom: '15px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <span style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>Mode : Appareil photo / Scan</span>
              <span className="badge b-blue" style={{ fontSize: '10px', fontFamily: 'IBM Plex Mono' }}>Session: {sessionId.substring(8)}</span>
            </div>

            {/* Upload Zone */}
            {!previewUrl ? (
              <label htmlFor="mobile-camera-input" style={{
                display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
                height: '240px', border: '2px dashed rgba(255,255,255,0.1)', borderRadius: '16px',
                cursor: 'pointer', background: 'rgba(255,255,255,0.01)', transition: 'all 0.2s',
                marginBottom: '20px'
              }}>
                <div style={{ width: '48px', height: '48px', borderRadius: '50%', background: 'rgba(187, 251, 149, 0.1)', color: 'var(--primary)', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: '15px' }}>
                  <Camera size={24} />
                </div>
                <span style={{ fontWeight: 600, fontSize: '15px', marginBottom: '5px' }}>Prendre en photo la facture</span>
                <span style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>ou choisir un fichier local</span>
                <input 
                  type="file" 
                  id="mobile-camera-input" 
                  accept="image/*" 
                  capture="environment" 
                  style={{ display: 'none' }} 
                  onChange={handleFileChange} 
                />
              </label>
            ) : (
              <div style={{ marginBottom: '20px' }}>
                <div style={{ position: 'relative', borderRadius: '16px', overflow: 'hidden', height: '240px', background: '#000', border: '1px solid rgba(255,255,255,0.05)' }}>
                  <img src={previewUrl} alt="Preview" style={{ width: '100%', height: '100%', objectFit: 'contain' }} />
                  <button 
                    onClick={resetPage} 
                    style={{ position: 'absolute', top: '10px', right: '10px', background: 'rgba(0,0,0,0.6)', border: 'none', color: '#fff', padding: '5px 10px', borderRadius: '20px', fontSize: '11px', cursor: 'pointer' }}
                  >
                    Reprendre
                  </button>
                </div>
              </div>
            )}

            {/* Error Message */}
            {status === 'error' && (
              <div className="banner danger" style={{ marginBottom: '20px' }}>
                <AlertCircle size={18} />
                <div>
                  <div className="banner-title">Erreur d'envoi</div>
                  <div className="banner-text">{errorMessage}</div>
                </div>
              </div>
            )}

            {/* Action Button */}
            <button 
              className="btn btn-primary full-width" 
              onClick={handleUpload}
              disabled={!file || status === 'loading'}
              style={{
                height: '48px', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '10px', fontSize: '15px', fontWeight: 600
              }}
            >
              {status === 'loading' ? (
                <>
                  <RefreshCw className="animate-spin" size={18} /> Transmission en cours...
                </>
              ) : (
                <>
                  <UploadCloud size={18} /> Envoyer à mon ordinateur
                </>
              )}
            </button>
          </div>
        )}

        <div style={{ textAlign: 'center', marginTop: '30px', fontSize: '11px', color: 'var(--text-muted)' }}>
          Sécurité CEO.IT — Données cryptées de bout en bout
        </div>
      </div>
    </div>
  );
};

export default MobileUploadPage;
