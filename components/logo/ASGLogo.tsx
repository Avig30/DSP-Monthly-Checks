import React from 'react'

interface ASGLogoProps {
  className?: string
  size?: 'sm' | 'md' | 'lg'
  variant?: 'full' | 'icon'
}

export default function ASGLogo({ className = '', size = 'md', variant = 'full' }: ASGLogoProps) {
  const sizes = { sm: { h: 32, text1: 20, text2: 9 }, md: { h: 48, text1: 30, text2: 13 }, lg: { h: 72, text1: 46, text2: 19 } }
  const s = sizes[size]

  const Icon = () => (
    <svg width={s.h * 0.85} height={s.h} viewBox="0 0 80 90" fill="none" xmlns="http://www.w3.org/2000/svg">
      {/* Green top leaf */}
      <ellipse cx="40" cy="18" rx="12" ry="18" fill="#7CB96A" transform="rotate(-5 40 18)"/>
      <path d="M40 5 Q45 18 40 32 Q35 18 40 5Z" fill="white" opacity="0.3"/>
      {/* Person figure top */}
      <circle cx="40" cy="6" r="4" fill="#7CB96A"/>
      {/* Teal right leaf */}
      <ellipse cx="56" cy="45" rx="10" ry="16" fill="#0D9488" transform="rotate(35 56 45)"/>
      <path d="M50 35 Q58 45 52 58 Q46 46 50 35Z" fill="white" opacity="0.25"/>
      {/* Blue left large leaf */}
      <ellipse cx="24" cy="52" rx="14" ry="10" fill="#2E6EA6" transform="rotate(-30 24 52)"/>
      <path d="M14 46 Q24 52 30 62 Q18 58 14 46Z" fill="white" opacity="0.2"/>
      {/* Blue lower left leaf */}
      <ellipse cx="18" cy="66" rx="12" ry="8" fill="#1E5A9C" transform="rotate(-50 18 66)"/>
      {/* Dots */}
      <circle cx="12" cy="72" r="3.5" fill="#2E6EA6"/>
      <circle cx="32" cy="74" r="2.5" fill="#0D9488"/>
      <circle cx="45" cy="70" r="2" fill="#0D9488"/>
    </svg>
  )

  if (variant === 'icon') return <Icon />

  return (
    <div className={`flex items-center gap-2 ${className}`}>
      <Icon />
      <div className="flex flex-col leading-none">
        <span style={{ fontSize: s.text1, fontWeight: 800, color: '#1E3A5F', letterSpacing: '-0.5px', lineHeight: 1 }}>ASG</span>
        <span style={{ fontSize: s.text2, fontWeight: 600, color: '#0D9488', letterSpacing: '0.15em', lineHeight: 1.3 }}>HOME CARE</span>
      </div>
    </div>
  )
}
