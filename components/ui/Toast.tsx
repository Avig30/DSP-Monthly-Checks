import React from 'react'
type ToastVariant = 'success'|'error'|'warning'|'info'
interface ToastProps { id: string; message: string; variant: ToastVariant; onDismiss: (id: string) => void }

const styles: Record<ToastVariant, { bg: string; icon: string }> = {
  success: { bg: 'bg-green-50 border-green-200 text-green-800', icon: '✓' },
  error: { bg: 'bg-red-50 border-red-200 text-red-800', icon: '✕' },
  warning: { bg: 'bg-amber-50 border-amber-200 text-amber-800', icon: '⚠' },
  info: { bg: 'bg-blue-50 border-blue-200 text-blue-800', icon: 'ℹ' },
}

export default function Toast({ id, message, variant, onDismiss }: ToastProps) {
  const s = styles[variant]
  return (
    <div className={`flex items-center gap-3 px-4 py-3 rounded-xl border shadow-lg text-sm font-medium animate-slide-in ${s.bg} min-w-64 max-w-sm`}>
      <span className="flex-shrink-0 font-bold">{s.icon}</span>
      <span className="flex-1">{message}</span>
      <button onClick={() => onDismiss(id)} className="flex-shrink-0 opacity-60 hover:opacity-100 transition-opacity ml-2">✕</button>
    </div>
  )
}
