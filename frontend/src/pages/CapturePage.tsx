import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../api';
import {
  UploadCloud,
  CheckCircle,
  AlertCircle,
  Zap,
  RefreshCw,
  Smartphone,
  Scan,
  ShieldCheck,
  Sparkles,
  ArrowRight,
} from 'lucide-react';

const CapturePage = () => {
  const [file, setFile] = useState<File | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [extractedData, setExtractedData] = useState<any>(null);
  const navigate = useNavigate();

  // Unique session ID for QR Code pairing
  const [sessionId] = useState(() => 'session_' + Math.random().toString(36).substring(2, 9));
  const [localIp, setLocalIp] = useState<string>('');

  useEffect(() => {
    api.get('/local-ip')
      .then(res => {
        if (res.data && res.data.ip) {
          setLocalIp(res.data.ip);
        }
      })
      .catch(() => {});
  }, []);

  // Determine the mobile URL for the QR code
  const getMobileUrl = () => {
    const hostname = window.location.hostname;
    const isLocal = hostname === 'localhost' || hostname === '127.0.0.1';
    const displayHost = (isLocal && localIp) ? `${localIp}:3000` : window.location.host;
    return `${window.location.protocol}//${displayHost}/mobile-upload?session=${sessionId}`;
  };

  const mobileUrl = getMobileUrl();
  const qrCodeUrl = `https://api.qrserver.com/v1/create-qr-code/?size=150x150&color=1c0f38&data=${encodeURIComponent(mobileUrl)}`;

  // Polling for mobile uploads
  useEffect(() => {
    let interval: any;
    
    if (!extractedData && !loading) {
      interval = setInterval(async () => {
        try {
          const res = await api.get(`/upload/status/${sessionId}`);
          if (res.data && res.data.status === 'completed') {
            clearInterval(interval);
            setExtractedData(res.data.data.extracted_data);
            setSuccess(`Document reçu de votre mobile (${res.data.data.filename}). OCR IA réussi !`);
          }
        } catch (err) {
          // Silent polling errors
        }
      }, 2000);
    }

    return () => {
      if (interval) clearInterval(interval);
    };
  }, [sessionId, extractedData, loading]);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files.length > 0) {
      setFile(e.target.files[0]);
    }
  };

  const handleUpload = async () => {
    if (!file) return;
    setLoading(true);
    setError('');
    setSuccess('');
    
    try {
      const formData = new FormData();
      formData.append('file', file);
      
      const res = await api.post('/upload', formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      });
      
      setExtractedData(res.data.extracted_data);
      setSuccess("Extraction OCR réussie. Veuillez vérifier les données.");
    } catch (err: any) {
      setError("Erreur lors de l'extraction OCR.");
    } finally {
      setLoading(false);
    }
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setExtractedData({
      ...extractedData,
      [name]: name === 'ht' || name === 'tva' || name === 'ttc' ? parseFloat(value) || 0 : value
    });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    
    try {
      await api.post('/factures', extractedData);
      navigate('/factures');
    } catch (err) {
      setError("Erreur lors de la création de la facture.");
      setLoading(false);
    }
  };

  const renderSourceBadge = () => {
    if (!extractedData) return null;
    const source = extractedData.source;
    let label = 'Démo';
    let icon = null;
    let badgeClass = 'bg-secondary/20 text-secondary border-secondary/30';

    if (source === 'gemini_api') {
      label = 'Gemini AI';
      icon = <Zap size={14} className="text-[oklch(0.86_0.18_128)]" />;
      badgeClass = 'bg-primary text-primary-foreground border-primary/30';
    } else if (source === 'ocr_tesseract') {
      label = 'Tesseract OCR';
      badgeClass = 'bg-[oklch(0.86_0.18_128/0.15)] text-primary border-[oklch(0.86_0.18_128/0.3)]';
    }

    const confiance = extractedData.confiance;

    return (
      <div className="flex items-center gap-3 mb-4 flex-wrap">
        <span className={`inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-[10px] font-semibold tracking-wide uppercase border ${badgeClass}`}>
          {icon} {label}
        </span>
        {confiance != null && (
          <span className="text-[12px] text-muted-foreground font-mono-tight flex items-center gap-1">
            <Sparkles size={12} className="text-primary animate-pulse-dot" /> Confidence: {Math.round(confiance * 100)}%
          </span>
        )}
      </div>
    );
  };

  return (
    <div className="relative min-h-screen bg-background grain-bg pt-6 pb-24">
      {/* Ambient Orbs */}
      <div className="pointer-events-none absolute -top-40 -left-20 h-[300px] w-[300px] rounded-full bg-[oklch(0.86_0.18_128)] opacity-20 blur-3xl" />
      <div className="pointer-events-none absolute -bottom-40 -right-20 h-[300px] w-[300px] rounded-full bg-[oklch(0.28_0.06_155)] opacity-10 blur-3xl" />

      <div className="mx-auto max-w-[960px] px-5">
        <section className="animate-rise" style={{ animationDelay: '60ms' }}>
          <div className="flex items-center gap-2 text-xs text-muted-foreground">
            <Scan className="h-3.5 w-3.5" />
            <span className="font-mono-tight uppercase tracking-widest text-[10px]">Verify documents</span>
          </div>
          <h1 className="mt-2 font-display text-[44px] leading-[1.02] tracking-tight">
            Extract invoice data <br />
            <span className="italic">with cryptographic precision.</span>
          </h1>
        </section>

        <div className="mt-8 grid grid-cols-1 md:grid-cols-2 gap-6 items-start">
          
          {/* Left Column: Upload or QR scan */}
          <div className="relative rounded-3xl border border-border bg-card p-6 shadow-[0_20px_50px_-20px_oklch(0.22_0.03_155/0.15)] overflow-hidden animate-rise" style={{ animationDelay: '120ms' }}>
            <div className="absolute inset-x-0 top-0 h-px animate-shimmer" />
            
            <h2 className="font-display text-2xl italic mb-1">Document upload</h2>
            <p className="text-xs text-muted-foreground mb-4">Choose a local file or drop it directly into the frame.</p>
            
            {/* Viewport/Dropzone */}
            <div className="relative aspect-[3/2.2] rounded-2xl overflow-hidden bg-[oklch(0.18_0.03_155)] border border-border flex items-center justify-center p-6 text-center">
              {loading ? (
                // Scanning Laser Animation
                <div className="absolute inset-0 flex flex-col items-center justify-center bg-black/40 backdrop-blur-sm z-10">
                  <div className="absolute inset-x-0 top-0 h-16 bg-gradient-to-b from-[oklch(0.86_0.18_128/0.55)] to-transparent animate-scan" />
                  <RefreshCw className="h-8 w-8 text-[oklch(0.86_0.18_128)] animate-spin mb-3" />
                  <p className="text-white font-mono-tight uppercase tracking-widest text-[11px]">AI extraction active</p>
                </div>
              ) : null}

              <input 
                type="file" 
                id="file-upload" 
                className="hidden" 
                onChange={handleFileChange}
                accept=".pdf,.png,.jpg,.jpeg"
              />
              <label htmlFor="file-upload" className="cursor-pointer flex flex-col items-center gap-3 w-full h-full justify-center group">
                <div className="h-12 w-12 rounded-2xl bg-secondary flex items-center justify-center group-hover:scale-105 transition-transform">
                  <UploadCloud size={24} className="text-primary" />
                </div>
                <div className="text-sm font-semibold text-primary-foreground/90">
                  {file ? file.name : "Click or drag invoice here"}
                </div>
                <span className="text-[10px] text-muted-foreground font-mono-tight uppercase tracking-wider">
                  PDF, PNG, JPG, JPEG
                </span>
              </label>

              {/* Frame corners */}
              {["top-3 left-3 border-t-2 border-l-2 rounded-tl-xl", "top-3 right-3 border-t-2 border-r-2 rounded-tr-xl", "bottom-3 left-3 border-b-2 border-l-2 rounded-bl-xl", "bottom-3 right-3 border-b-2 border-r-2 rounded-br-xl"].map((pos, i) => (
                <div key={i} className={`absolute ${pos} h-6 w-6 border-[oklch(0.86_0.18_128/0.6)]`} />
              ))}
            </div>

            <button 
              className="mt-4 group w-full inline-flex items-center justify-center gap-2 rounded-2xl bg-primary text-primary-foreground py-3.5 text-sm font-medium hover:opacity-95 transition disabled:opacity-50" 
              onClick={handleUpload}
              disabled={!file || loading}
            >
              {loading ? "Processing..." : "Run OCR Extraction"}
              <ArrowRight className="h-4 w-4 group-hover:translate-x-0.5 transition" />
            </button>

            {/* QR Code section */}
            <div className="mt-6 pt-5 border-t border-border flex items-start gap-4">
              <div className="h-9 w-9 rounded-xl bg-secondary shrink-0 grid place-items-center">
                <Smartphone className="h-5 w-5 text-primary" />
              </div>
              <div className="flex-1 min-w-0">
                <div className="text-xs font-semibold">Mobile scan pair</div>
                <p className="text-[11px] text-muted-foreground leading-normal mt-1">
                  Point your smartphone camera at this QR code to capture invoices instantly.
                </p>
                <div className="mt-4 flex gap-4 items-center">
                  <div className="bg-white p-2 rounded-xl shadow-md border border-border">
                    <img src={qrCodeUrl} alt="Pairing QR" className="w-24 h-24 block" />
                  </div>
                  <div className="text-[10px] text-muted-foreground leading-snug">
                    Ensure both devices share the same local Wi-Fi connection.
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Right Column: Extracted fields */}
          <div className="relative rounded-3xl border border-border bg-card p-6 shadow-[0_20px_50px_-20px_oklch(0.22_0.03_155/0.15)] overflow-hidden animate-rise" style={{ animationDelay: '180ms' }}>
            <div className="absolute inset-x-0 top-0 h-px animate-shimmer" />

            <h2 className="font-display text-2xl italic mb-1">Extracted values</h2>
            <p className="text-xs text-muted-foreground mb-4">Validate extracted values against original document.</p>

            {error && (
              <div className="mb-4 p-3 rounded-2xl bg-destructive/10 border border-destructive/20 text-destructive text-xs flex items-start gap-2">
                <AlertCircle size={16} className="shrink-0 mt-0.5" />
                <span>{error}</span>
              </div>
            )}
            {success && (
              <div className="mb-4 p-3 rounded-2xl bg-[oklch(0.86_0.18_128/0.15)] border border-[oklch(0.86_0.18_128/0.3)] text-primary text-xs flex items-start gap-2">
                <CheckCircle size={16} className="shrink-0 mt-0.5" />
                <span>{success}</span>
              </div>
            )}

            {/* Warnings list */}
            {extractedData?.validation_warnings && extractedData.validation_warnings.length > 0 && (
              <div className="mb-4 space-y-2">
                {extractedData.validation_warnings.map((warn: string, i: number) => (
                  <div key={i} className="p-3 rounded-2xl bg-[oklch(0.55_0.2_27/0.08)] border border-[oklch(0.55_0.2_27/0.2)] text-[12px] leading-snug flex items-start gap-2.5">
                    <Zap className="h-4 w-4 text-[oklch(0.55_0.2_27)] mt-0.5 shrink-0" />
                    <span>{warn}</span>
                  </div>
                ))}
              </div>
            )}

            {!extractedData ? (
              <div className="flex flex-col items-center justify-center py-12 text-center border border-dashed border-border rounded-2xl bg-secondary/30">
                <div className="h-10 w-10 rounded-full bg-secondary flex items-center justify-center mb-3">
                  <Scan size={18} className="text-muted-foreground" />
                </div>
                <div className="text-sm font-medium text-muted-foreground">Waiting for document</div>
                <p className="text-xs text-muted-foreground max-w-[200px] mt-1">Upload a local file or scan using your phone pairing.</p>
              </div>
            ) : (
              <form onSubmit={handleSubmit} className="space-y-4">
                {renderSourceBadge()}
                
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  <label className="block">
                    <span className="text-[10px] uppercase tracking-widest text-muted-foreground">Fournisseur</span>
                    <input 
                      type="text" 
                      name="fournisseur" 
                      value={extractedData.fournisseur || ''} 
                      onChange={handleChange} 
                      required 
                      className="mt-1 w-full rounded-xl border border-border bg-background px-3 py-2 text-xs focus:outline-none focus:border-foreground/40"
                    />
                  </label>
                  <label className="block">
                    <span className="text-[10px] uppercase tracking-widest text-muted-foreground">Invoice N°</span>
                    <input 
                      type="text" 
                      name="numero" 
                      value={extractedData.numero || ''} 
                      onChange={handleChange} 
                      required 
                      className="mt-1 w-full rounded-xl border border-border bg-background px-3 py-2 text-xs focus:outline-none focus:border-foreground/40"
                    />
                  </label>
                  <label className="block">
                    <span className="text-[10px] uppercase tracking-widest text-muted-foreground">Date</span>
                    <input 
                      type="date" 
                      name="date_facture" 
                      value={extractedData.date_facture || ''} 
                      onChange={handleChange} 
                      required 
                      className="mt-1 w-full rounded-xl border border-border bg-background px-3 py-2 text-xs focus:outline-none focus:border-foreground/40"
                    />
                  </label>
                  <label className="block">
                    <span className="text-[10px] uppercase tracking-widest text-muted-foreground">Currency</span>
                    <input 
                      type="text" 
                      name="devise" 
                      value={extractedData.devise || 'EUR'} 
                      onChange={handleChange} 
                      className="mt-1 w-full rounded-xl border border-border bg-background px-3 py-2 text-xs focus:outline-none focus:border-foreground/40"
                    />
                  </label>
                  <label className="block">
                    <span className="text-[10px] uppercase tracking-widest text-muted-foreground">Montant HT</span>
                    <input 
                      type="number" 
                      step="0.001" 
                      name="ht" 
                      value={extractedData.ht ?? ''} 
                      onChange={handleChange} 
                      className="mt-1 w-full rounded-xl border border-border bg-background px-3 py-2 text-xs focus:outline-none focus:border-foreground/40"
                    />
                  </label>
                  <label className="block">
                    <span className="text-[10px] uppercase tracking-widest text-muted-foreground">TVA</span>
                    <input 
                      type="number" 
                      step="0.001" 
                      name="tva" 
                      value={extractedData.tva ?? ''} 
                      onChange={handleChange} 
                      className="mt-1 w-full rounded-xl border border-border bg-background px-3 py-2 text-xs focus:outline-none focus:border-foreground/40"
                    />
                  </label>
                  <label className="block sm:col-span-2">
                    <span className="text-[10px] uppercase tracking-widest text-muted-foreground">Montant TTC</span>
                    <input 
                      type="number" 
                      step="0.001" 
                      name="ttc" 
                      value={extractedData.ttc ?? ''} 
                      onChange={handleChange} 
                      required 
                      className="mt-1 w-full rounded-xl border border-border bg-background px-3 py-2 text-xs font-semibold focus:outline-none focus:border-foreground/40"
                    />
                  </label>
                  <label className="block sm:col-span-2">
                    <span className="text-[10px] uppercase tracking-widest text-muted-foreground">IBAN</span>
                    <input 
                      type="text" 
                      name="iban" 
                      value={extractedData.iban || ''} 
                      onChange={handleChange} 
                      className="mt-1 w-full rounded-xl border border-border bg-background px-3 py-2 text-xs font-mono-tight focus:outline-none focus:border-foreground/40"
                    />
                  </label>
                </div>

                <div className="pt-2">
                  <button type="submit" disabled={loading} className="w-full rounded-2xl bg-primary text-primary-foreground py-3.5 text-xs font-semibold hover:opacity-95 transition inline-flex items-center justify-center gap-1.5">
                    Verify &amp; Save Invoice
                    <ArrowRight className="h-4 w-4" />
                  </button>
                </div>
              </form>
            )}
          </div>
        </div>

        {/* Footer */}
        <section className="mt-8 flex items-center justify-center gap-2 text-[10px] uppercase tracking-[0.22em] text-muted-foreground">
          <ShieldCheck className="h-3 w-3" />
          End-to-end signed · SOC 2 Audit Ready
        </section>
      </div>
    </div>
  );
};

export default CapturePage;
