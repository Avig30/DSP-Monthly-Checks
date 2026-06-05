import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'
import { ToastProvider } from '@/components/ui/ToastProvider'
const inter = Inter({ subsets: ['latin'], variable: '--font-inter', display: 'swap' })
export const metadata: Metadata = { title: 'ASG Care Solutions', description: 'Operations. Management. Notes. Intelligence.' }
export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={inter.variable}>
      <body className="font-sans antialiased bg-slate-50">
        <ToastProvider>{children}</ToastProvider>
      </body>
    </html>
  )
}
