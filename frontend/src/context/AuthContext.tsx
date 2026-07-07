import { createContext, useState, useEffect } from 'react';
import type { ReactNode } from 'react';
import type React from 'react';
import api from '../api';

export interface User {
  id: number;
  nom: string;
  email: string;
  role: string;
}

interface AuthContextType {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  login: (token: string, userData: User) => void;
  logout: () => void;
  demoRole: string | null;
  setDemoRole: (role: string) => void;
  activeTab: string;
  setActiveTab: (tab: string) => void;
}

export const AuthContext = createContext<AuthContextType>({
  user: null,
  token: null,
  isAuthenticated: false,
  login: () => {},
  logout: () => {},
  demoRole: null,
  setDemoRole: () => {},
  activeTab: 'dashboard',
  setActiveTab: () => {},
});

export const AuthProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [token, setToken] = useState<string | null>(localStorage.getItem('token'));
  const [isLoading, setIsLoading] = useState(true);
  const [demoRole, setDemoRoleState] = useState<string | null>(null);
  const [activeTab, setActiveTabState] = useState<string>('dashboard');

  useEffect(() => {
    const fetchUser = async () => {
      if (token) {
        try {
          const res = await api.get('/auth/me');
          setUser(res.data);
          setDemoRoleState(res.data.role);
        } catch (error) {
          console.error("Failed to fetch user", error);
          logout();
        }
      }
      setIsLoading(false);
    };
    fetchUser();
  }, [token]);

  const login = (newToken: string, userData: User) => {
    localStorage.setItem('token', newToken);
    setToken(newToken);
    setUser(userData);
    setDemoRoleState(userData.role);
    setActiveTabState('dashboard');
  };

  const logout = () => {
    localStorage.removeItem('token');
    setToken(null);
    setUser(null);
    setDemoRoleState(null);
    setActiveTabState('dashboard');
  };

  if (isLoading) {
    return <div style={{ color: 'white', padding: '2rem' }}>Chargement...</div>;
  }

  const setDemoRole = (role: string) => {
    setDemoRoleState(role);
    setActiveTabState('dashboard'); // reset tab on role switch
  };

  const setActiveTab = (tab: string) => {
    setActiveTabState(tab);
  };

  return (
    <AuthContext.Provider value={{ user, token, isAuthenticated: !!token, login, logout, demoRole, setDemoRole, activeTab, setActiveTab }}>
      {children}
    </AuthContext.Provider>
  );
};
