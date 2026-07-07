import { useState, useEffect } from 'react';
import { useSearchParams } from 'react-router-dom';
import { Camera, CheckCircle, UploadCloud, AlertCircle, RefreshCw } from 'lucide-react';
import axios from 'axios';

const MobileUploadPage = () => {
  const [searchParams] = useSearchParams();
  const sessionId = searchParams.get('session');
  
  const [file, setFile] = useState<File | null>(null);
  const [previewUrl, setPreviewUrl] = useState<string | null>(null);
  const [status, setStatus] = useState<'idle' | 'loading' | 'success' | 'error'>('idle');
  const [errorMessage, setErrorMessage] = useState<string>('');

  useEffect(() => {
    // Generate clean page title
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
      // Find API host. In mobile, window.location.origin is the frontend address.
      // The API server runs on port 8000 (development) or same host (production).
      const backendUrl = window.location.origin.includes('localhost') 
        ? 'http://localhost:8000' 
        : window.location.origin.replace(':3000', ':8000'); // dev override for React dev server

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
      <div className="layout" style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', background: '#1c0f38', color: '#fff', padding: '20px', fontFamily: 'Inter, sans-serif' }}>
        <div className="card glass-card text-center" style={{ padding: '2rem', maxWidth: '400px' }}>
          <AlertCircle size={48} className="text-red" style={{ margin: '0 auto 1.5rem', color: '#f44336' }} />
          <h2 style={{ fontFamily: 'Sora', fontWeight: 700, marginBottom: '1rem' }}>Session manquante</h2>
          <p style={{ color: '#94a3b8', fontSize: '14px', lineHeight: 1.5 }}>
            Cette page doit être ouverte en scannant le QR code affiché sur l'écran de votre ordinateur.
          </p>
        </div>
      </div>
    );
  }

  return (
    <div style={{ minHeight: '100vh', background: '#12072b', color: '#fff', fontFamily: 'Inter, sans-serif', padding: '20px 15px' }}>
      <div style={{ maxWidth: '480px', margin: '0 auto' }}>
        
        {/* Brand header */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '25px', justifyContent: 'center' }}>
          <div style={{
            width: '32px', height: '32px', borderRadius: '8px',
            background: 'linear-gradient(135deg, #3b7ddb, #f4841f)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontFamily: 'Sora', fontWeight: 800, color: '#12072b', fontSize: '14px'
          }}>
            CI
          </div>
          <div style={{ fontFamily: 'Sora', fontWeight: 700, fontSize: '18px' }}>CEO.IT Mobile</div>
        </div>

        {status === 'success' ? (
          <div className="card glass-card text-center" style={{ padding: '2.5rem 1.5rem', background: 'rgba(255,255,255,0.03)', borderRadius: '16px', border: '1px solid rgba(255,255,255,0.08)' }}>
            <div style={{ display: 'inline-flex', alignItems: 'center', justifyContent: 'center', width: '64px', height: '64px', borderRadius: '50%', background: 'rgba(30,158,107,0.1)', color: '#1e9e6b', marginBottom: '1.5rem', transform: 'scale(1)', animation: 'pulse 2s infinite' }}>
              <CheckCircle size={36} />
            </div>
            <h2 style={{ fontFamily: 'Sora', fontWeight: 700, fontSize: '20px', marginBottom: '10px' }}>Document Envoyé !</h2>
            <p style={{ color: '#94a3b8', fontSize: '14px', marginBottom: '2rem', lineHeight: 1.5 }}>
              L'analyse OCR IA est lancée. Les données extraites vont s'afficher automatiquement sur l'écran de votre ordinateur.
            </p>
            <button className="btn btn-outline full-width" onClick={resetPage} style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px' }}>
              <RefreshCw size={16} /> Envoyer un autre document
            </button>
          </div>
        ) : (
          <div className="card glass-card" style={{ padding: '20px', background: 'rgba(255,255,255,0.03)', borderRadius: '16px', border: '1px solid rgba(255,255,255,0.08)' }}>
            <div style={{ marginBottom: '15px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <span style={{ fontSize: '12px', color: '#94a3b8' }}>Mode : Appareil photo / Scan</span>
              <span className="badge b-blue" style={{ fontSize: '10px', fontFamily: 'IBM Plex Mono' }}>Session: {sessionId.substring(8)}</span>
            </div>

            {/* Upload Zone */}
            {!previewUrl ? (
              <label htmlFor="mobile-camera-input" style={{
                display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
                height: '240px', border: '2px dashed rgba(255,255,255,0.15)', borderRadius: '12px',
                cursor: 'pointer', background: 'rgba(255,255,255,0.01)', transition: 'all 0.2s',
                marginBottom: '20px'
              }}>
                <div style={{ width: '48px', height: '48px', borderRadius: '50%', background: 'rgba(59,125,219,0.1)', color: '#3b7ddb', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: '15px' }}>
                  <Camera size={24} />
                </div>
                <span style={{ fontWeight: 600, fontSize: '15px', marginBottom: '5px' }}>Prendre en photo la facture</span>
                <span style={{ fontSize: '11px', color: '#64748b' }}>ou choisir un fichier local</span>
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
                <div style={{ position: 'relative', borderRadius: '12px', overflow: 'hidden', height: '240px', background: '#000', border: '1px solid rgba(255,255,255,0.1)' }}>
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

        <div style={{ textAlign: 'center', marginTop: '30px', fontSize: '11px', color: '#4a3d70' }}>
          Sécurité CEO.IT — Données cryptées de bout en bout
        </div>
      </div>
    </div>
  );
};

export default MobileUploadPage;
