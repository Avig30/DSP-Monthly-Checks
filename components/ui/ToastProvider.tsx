'use client'
import React, { createContext, useContext, useState, useCallback } from 'react'
import Toast from './Toast'

type ToastVariant = 'success'|'error'|'warning'|'info'
interface ToastItem { id: string; message: string; variant: ToastVariant }
interface ToastContextValue { toast: { success: (m: string) => void; error: (m: string) => void; warning: (m: string) => void; info: (m: string) => void } }

const ToastContext = createContext<ToastContextValue>({ toast: { success: () => {}, error: () => {}, warning: () => {}, info: () => {} } })
export const useToast = () => useContext(ToastContext)

export function ToastProvider({ children }: { children: React.ReactNode }) {
  const [toasts, setToasts] = useState<ToastItem[]>([])

  const addToast = useCallback((message: string, variant: ToastVariant) => {
    const id = Math.random().toString(36).slice(2)
    setToasts(prev => [...prev.slice(-4), { id, message, variant }])
    setTimeout(() => setToasts(prev => prev.filter(t => t.id !== id)), 5000)
  }, [])

  const dismiss = useCallback((id: string) => setToasts(prev => prev.filter(t => t.id !== id)), [])

  const toast = { success: (m: string) => addToast(m, 'success'), error: (m: string) => addToast(m, 'error'), warning: (m: string) => addToast(m, 'warning'), info: (m: string) => addToast(m, 'info') }

  return (
    <ToastContext.Provider value={{ toast }}>
      {children}
      <div className="fixed bottom-4 right-4 z-[100] flex flex-col gap-2">
        {toasts.map(t => <Toast key={t.id} {...t} onDismiss={dismiss}/>)}
      </div>
    </ToastContext.Provider>
  )
}
