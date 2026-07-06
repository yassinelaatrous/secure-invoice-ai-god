import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../api';
import { UploadCloud, CheckCircle, AlertCircle, Zap } from 'lucide-react';

const CapturePage = () => {
  const [file, setFile] = useState<File | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [extractedData, setExtractedData] = useState<any>(null);
  const navigate = useNavigate();

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files.length > 0) {
      setFile(e.target.files[0]);
    }
  };

  const handleUpload = async () => {
    if (!file) return;
    setLoading(true);
    setError('');
    
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
    let badgeClass = 'badge-outline';

    if (source === 'gemini_api') {
      label = 'Gemini AI';
      icon = <Zap size={14} />;
      badgeClass = 'badge-primary';
    } else if (source === 'ocr_tesseract') {
      label = 'Tesseract OCR';
      badgeClass = 'badge-success';
    }

    const confiance = extractedData.confiance;

    return (
      <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', marginBottom: '0.75rem', flexWrap: 'wrap' }}>
        <span className={`badge ${badgeClass}`} style={{ display: 'inline-flex', alignItems: 'center', gap: '0.3rem' }}>
          {icon} {label}
        </span>
        {confiance != null && (
          <span style={{ fontSize: '0.85rem', color: '#94a3b8' }}>
            Confiance&nbsp;: {Math.round(confiance * 100)}%
          </span>
        )}
      </div>
    );
  };

  return (
    <div className="capture-page">
      <div className="capture-container">
        
        {/* Colonne de gauche: Upload & Aperçu */}
        <div className="upload-section glass-card">
          <h2>Document Source</h2>
          
          <div className="upload-zone">
            <input 
              type="file" 
              id="file-upload" 
              className="hidden-input" 
              onChange={handleFileChange}
              accept=".pdf,.png,.jpg,.jpeg"
            />
            <label htmlFor="file-upload" className="upload-label">
              <UploadCloud size={48} color="#6366f1" />
              <p>{file ? file.name : "Cliquez ou glissez une facture ici"}</p>
              <span className="upload-hint">Support: PDF, PNG, JPG</span>
            </label>
          </div>

          <button 
            className="btn btn-primary full-width" 
            onClick={handleUpload}
            disabled={!file || loading}
            style={{ marginTop: '1rem' }}
          >
            {loading ? "Analyse IA en cours..." : "Lancer l'OCR"}
          </button>


        </div>

        {/* Colonne de droite: Données extraites */}
        <div className="data-section glass-card">
          <h2>Données Extraites</h2>
          
          {error && <div className="alert error"><AlertCircle size={18}/> {error}</div>}
          {success && <div className="alert success"><CheckCircle size={18}/> {success}</div>}

          {extractedData?.validation_warnings && extractedData.validation_warnings.length > 0 && (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem', marginBottom: '0.75rem' }}>
              {extractedData.validation_warnings.map((warn: string, i: number) => (
                <div key={i} className="alert warning" style={{ background: 'rgba(234, 179, 8, 0.1)', borderColor: '#eab308', color: '#eab308' }}>
                  <AlertCircle size={18} /> {warn}
                </div>
              ))}
            </div>
          )}

          {!extractedData ? (
            <div className="empty-state">
              Veuillez uploader un document pour lancer l'extraction.
            </div>
          ) : (
            <form onSubmit={handleSubmit} className="extracted-form">
              {renderSourceBadge()}
              <div className="form-grid">
                <div className="form-group">
                  <label>Fournisseur</label>
                  <input type="text" name="fournisseur" value={extractedData.fournisseur || ''} onChange={handleChange} required />
                </div>
                <div className="form-group">
                  <label>Numéro de facture</label>
                  <input type="text" name="numero" value={extractedData.numero || ''} onChange={handleChange} required />
                </div>
                <div className="form-group">
                  <label>Date</label>
                  <input type="date" name="date_facture" value={extractedData.date_facture || ''} onChange={handleChange} required />
                </div>
                <div className="form-group">
                  <label>Devise</label>
                  <input type="text" name="devise" value={extractedData.devise || 'EUR'} onChange={handleChange} />
                </div>
                <div className="form-group">
                  <label>Montant HT</label>
                  <input type="number" step="0.001" name="ht" value={extractedData.ht ?? ''} onChange={handleChange} />
                </div>
                <div className="form-group">
                  <label>Montant TVA</label>
                  <input type="number" step="0.001" name="tva" value={extractedData.tva ?? ''} onChange={handleChange} />
                </div>
                <div className="form-group">
                  <label>Montant TTC</label>
                  <input type="number" step="0.001" name="ttc" value={extractedData.ttc ?? ''} onChange={handleChange} required />
                </div>
                <div className="form-group full-width">
                  <label>IBAN</label>
                  <input type="text" name="iban" value={extractedData.iban || ''} onChange={handleChange} />
                </div>
              </div>

              <div className="form-actions">
                <button type="submit" className="btn btn-success full-width" disabled={loading}>
                  {loading ? "Enregistrement..." : "Vérifier la conformité & Enregistrer"}
                </button>
              </div>
            </form>
          )}
        </div>

      </div>
    </div>
  );
};

export default CapturePage;
