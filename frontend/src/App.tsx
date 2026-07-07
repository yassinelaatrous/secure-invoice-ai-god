import { useContext } from 'react';
import type { ReactNode } from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import Layout from './components/Layout';
import LoginPage from './pages/LoginPage';
import Dashboard from './pages/Dashboard';
import MobileUploadPage from './pages/MobileUploadPage';
import { AuthContext } from './context/AuthContext';

const ProtectedRoute = ({ children, requiredRole }: { children: ReactNode, requiredRole?: string }) => {
  const { isAuthenticated, user } = useContext(AuthContext);
  
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  if (requiredRole && user?.role !== requiredRole && user?.role !== 'admin') {
    return <Navigate to="/" replace />;
  }

  return children;
};

function App() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route path="/mobile-upload" element={<MobileUploadPage />} />
      
      <Route path="/" element={<ProtectedRoute><Layout /></ProtectedRoute>}>
        <Route index element={<Dashboard />} />
        <Route path="dossier" element={<Dashboard />} />
        <Route path="documents" element={<Dashboard />} />
        <Route path="factures" element={<Dashboard />} />
        <Route path="echeances" element={<Dashboard />} />
        <Route path="messagerie" element={<Dashboard />} />
        <Route path="rdv" element={<Dashboard />} />
        <Route path="parametres" element={<Dashboard />} />
        <Route path="dossiers" element={<Dashboard />} />
        <Route path="comptabilite" element={<Dashboard />} />
        <Route path="taches" element={<Dashboard />} />
        <Route path="rapports" element={<Dashboard />} />
        <Route path="clients" element={<Dashboard />} />
        <Route path="utilisateurs" element={<Dashboard />} />
        <Route path="fiscalite" element={<Dashboard />} />
        <Route path="securite" element={<Dashboard />} />
        
        {/* Backwards compatibility */}
        <Route path="capture" element={<Dashboard />} />
        <Route path="admin" element={<Dashboard />} />
      </Route>
      
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}

export default App;
