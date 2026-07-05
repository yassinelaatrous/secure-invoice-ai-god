import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../api';
import { UploadCloud, CheckCircle, AlertCircle } from 'lucide-react';

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

  // Simulation pour la démo
  const loadDemoFile = async (type: string) => {
    // Créer un fichier factice pour l'upload
    const dummyFile = new File(["dummy content"], `facture_${type}.pdf`, { type: "application/pdf" });
    setFile(dummyFile);
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
            {loading ? "Extraction en cours..." : "Lancer l'OCR"}
          </button>

          <div className="demo-buttons" style={{ marginTop: '2rem' }}>
            <p>Fichiers de test (Démo):</p>
            <div className="btn-group">
              <button className="btn btn-outline btn-sm" onClick={() => loadDemoFile('steg')}>STEG (Valide)</button>
              <button className="btn btn-outline btn-sm" onClick={() => loadDemoFile('fraud')}>Fraude IBAN</button>
              <button className="btn btn-outline btn-sm" onClick={() => loadDemoFile('calcul')}>Erreur TVA</button>
            </div>
          </div>
        </div>

        {/* Colonne de droite: Données extraites */}
        <div className="data-section glass-card">
          <h2>Données Extraites</h2>
          
          {error && <div className="alert error"><AlertCircle size={18}/> {error}</div>}
          {success && <div className="alert success"><CheckCircle size={18}/> {success}</div>}

          {!extractedData ? (
            <div className="empty-state">
              Veuillez uploader un document pour lancer l'extraction.
            </div>
          ) : (
            <form onSubmit={handleSubmit} className="extracted-form">
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
                  <input type="number" step="0.01" name="ht" value={extractedData.ht || 0} onChange={handleChange} />
                </div>
                <div className="form-group">
                  <label>Montant TVA</label>
                  <input type="number" step="0.01" name="tva" value={extractedData.tva || 0} onChange={handleChange} />
                </div>
                <div className="form-group">
                  <label>Montant TTC</label>
                  <input type="number" step="0.01" name="ttc" value={extractedData.ttc || 0} onChange={handleChange} required />
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
