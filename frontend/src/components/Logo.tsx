import React from 'react';

interface LogoProps {
  size?: number;
  className?: string;
}

const Logo: React.FC<LogoProps> = ({ size = 34, className }) => {
  return (
    <svg 
      viewBox="0 0 100 100" 
      width={size} 
      height={size} 
      fill="none" 
      xmlns="http://www.w3.org/2000/svg"
      className={className}
    >
      <defs>
        <linearGradient id="logo-gradient" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stopColor="#bbfb95" /> {/* Lime Green */}
          <stop offset="50%" stopColor="#b199f8" /> {/* Soft Purple */}
          <stop offset="100%" stopColor="#d48a52" /> {/* Glow Orange */}
        </linearGradient>
        <filter id="logo-glow" x="-20%" y="-20%" width="140%" height="140%">
          <feGaussianBlur stdDeviation="3" result="blur" />
          <feComposite in="SourceGraphic" in2="blur" operator="over" />
        </filter>
      </defs>
      
      {/* Outer abstract tech shape (Hexagon with rounded vertices) */}
      <polygon 
        points="50,12 85,32 85,68 50,88 15,68 15,32" 
        stroke="url(#logo-gradient)" 
        strokeWidth="5.5" 
        strokeLinejoin="round"
        filter="url(#logo-glow)"
      />
      
      {/* Document parallel lines (Representing Invoice) */}
      <line x1="32" y1="42" x2="68" y2="42" stroke="white" strokeWidth="5" strokeLinecap="round" opacity="0.9" />
      <line x1="32" y1="54" x2="52" y2="54" stroke="white" strokeWidth="5" strokeLinecap="round" opacity="0.9" />
      
      {/* The glowing AI node */}
      <circle cx="64" cy="54" r="5.5" fill="#bbfb95" filter="url(#logo-glow)">
        <animate attributeName="opacity" values="0.6;1;0.6" dur="3s" repeatCount="indefinite" />
      </circle>
    </svg>
  );
};

export default Logo;
