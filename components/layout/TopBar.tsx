'use client'
import { useEffect, useState } from 'react'
import { usePathname } from 'next/navigation'
import { createClient } from '@/lib/supabase'

const BREADCRUMBS: Record<string, string> = {
  '/dashboard': 'Dashboard',
  '/participants': 'Participants',
  '/referrals': 'Referrals',
  '/referrals/sc-pipeline': 'SC Pipeline',
  '/hr/hiring': 'HR / Hiring',
  '/compliance': 'Compliance',
  '/authorizations': 'Authorizations',
  '/service-notes': 'Service Notes',
  '/evv': 'EVV Clock-In',
  '/incidents': 'Incidents',
  '/qa': 'QA Check-ins',
  '/behavioral': 'Behavioral',
  '/analytics': 'Analytics',
  '/assistant': 'AI Assistant',
  '/settings': 'Settings',
  '/onboarding': 'Onboarding',
}

const ROLE_COLORS: Record<string, string> = {
  admin: 'bg-purple-100 text-purple-700',
  case_manager: 'bg-blue-100 text-blue-700',
  dsp: 'bg-green-100 text-green-700',
  bcba: 'bg-amber-100 text-amber-700',
  sc_portal: 'bg-slate-100 text-slate-700',
  family: 'bg-pink-100 text-pink-700',
}

export default function TopBar() {
  const pathname = usePathname()
  const [userName, setUserName] = useState('')
  const [role, setRole] = useState('')

  useEffect(() => {
    const supabase = createClient()
    supabase.auth.getUser().then(({ data: { user } }) => {
      if (!user) return
      supabase.from('user_profiles').select('role,first_name,last_name').eq('id', user.id).single()
        .then(({ data }) => {
          if (data) {
            setRole(data.role)
            setUserName(`${data.first_name || ''} ${data.last_name || ''}`.trim() || user.email || '')
          }
        })
    })
  }, [])

  const segments = pathname.split('/').filter(Boolean)
  const breadcrumb = BREADCRUMBS[pathname] || segments.map(s => s.charAt(0).toUpperCase() + s.slice(1).replace(/-/g, ' ')).join(' / ')

  return (
    <div className="h-14 bg-white border-b border-slate-200 flex items-center px-6 gap-4 flex-shrink-0">
      <div className="flex-1">
        <p className="text-sm font-semibold text-slate-800">{breadcrumb}</p>
      </div>
      <div className="flex items-center gap-3">
        {role && (
          <span className={`text-xs font-medium px-2.5 py-1 rounded-full capitalize ${ROLE_COLORS[role] || 'bg-slate-100 text-slate-700'}`}>
            {role.replace('_', ' ')}
          </span>
        )}
        <span className="text-sm text-slate-700 font-medium">{userName}</span>
      </div>
    </div>
  )
}
