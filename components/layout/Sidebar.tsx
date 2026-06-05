'use client'
import { useEffect, useState } from 'react'
import Link from 'next/link'
import { usePathname, useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase'
import ASGLogo from '@/components/logo/ASGLogo'
import type { UserRole } from '@/types'

interface NavItem {
  href: string
  label: string
  roles: UserRole[]
  icon: React.ReactNode
  children?: { href: string; label: string }[]
}

const Icon = ({ d }: { d: string }) => (
  <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={1.8}>
    <path strokeLinecap="round" strokeLinejoin="round" d={d}/>
  </svg>
)

const navItems: NavItem[] = [
  { href: '/dashboard', label: 'Dashboard', roles: ['admin','case_manager'], icon: <Icon d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"/> },
  { href: '/participants', label: 'Participants', roles: ['admin','case_manager','dsp','bcba','sc_portal'], icon: <Icon d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"/> },
  { href: '/referrals', label: 'Referrals', roles: ['admin','case_manager'], icon: <Icon d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/>, children: [{ href: '/referrals/sc-pipeline', label: 'SC Pipeline' }] },
  { href: '/hr/hiring', label: 'HR / Hiring', roles: ['admin','case_manager'], icon: <Icon d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z"/> },
  { href: '/compliance', label: 'Compliance', roles: ['admin','case_manager'], icon: <Icon d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/> },
  { href: '/authorizations', label: 'Authorizations', roles: ['admin','case_manager'], icon: <Icon d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/> },
  { href: '/service-notes', label: 'Service Notes', roles: ['admin','case_manager','dsp'], icon: <Icon d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/> },
  { href: '/evv', label: 'EVV Clock-In', roles: ['dsp'], icon: <Icon d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/> },
  { href: '/incidents', label: 'Incidents', roles: ['admin','case_manager','dsp'], icon: <Icon d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/> },
  { href: '/qa', label: 'QA Check-ins', roles: ['admin','case_manager'], icon: <Icon d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4"/> },
  { href: '/behavioral', label: 'Behavioral', roles: ['bcba'], icon: <Icon d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"/> },
  { href: '/analytics', label: 'Analytics', roles: ['admin'], icon: <Icon d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/> },
  { href: '/assistant', label: 'AI Assistant', roles: ['admin','case_manager'], icon: <Icon d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z"/> },
  { href: '/settings', label: 'Settings', roles: ['admin'], icon: <Icon d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z M15 12a3 3 0 11-6 0 3 3 0 016 0z"/> },
]

export default function Sidebar() {
  const pathname = usePathname()
  const router = useRouter()
  const [role, setRole] = useState<UserRole | null>(null)
  const [userName, setUserName] = useState('')
  const [expandedItems, setExpandedItems] = useState<string[]>([])

  useEffect(() => {
    const supabase = createClient()
    supabase.auth.getUser().then(({ data: { user } }) => {
      if (!user) return
      supabase.from('user_profiles').select('role,first_name,last_name').eq('id', user.id).single()
        .then(({ data }) => {
          if (data) {
            setRole(data.role as UserRole)
            setUserName(`${data.first_name || ''} ${data.last_name || ''}`.trim() || user.email || '')
          }
        })
    })
  }, [])

  async function handleSignOut() {
    const supabase = createClient()
    await supabase.auth.signOut()
    router.push('/auth/login')
  }

  const toggleExpand = (href: string) => {
    setExpandedItems(prev => prev.includes(href) ? prev.filter(h => h !== href) : [...prev, href])
  }

  const filteredItems = role ? navItems.filter(item => item.roles.includes(role)) : []

  return (
    <div className="w-64 bg-white border-r border-slate-200 flex flex-col h-full flex-shrink-0">
      <div className="p-4 border-b border-slate-100">
        <ASGLogo size="sm" />
      </div>

      <nav className="flex-1 overflow-y-auto py-3 px-2">
        {filteredItems.map(item => {
          const isActive = pathname === item.href || pathname.startsWith(item.href + '/')
          const isExpanded = expandedItems.includes(item.href)

          return (
            <div key={item.href}>
              <div
                className={`flex items-center gap-2.5 px-3 py-2 rounded-lg mb-0.5 cursor-pointer transition-colors text-sm font-medium ${
                  isActive ? 'text-white' : 'text-slate-600 hover:bg-slate-100 hover:text-slate-900'
                }`}
                style={isActive ? { backgroundColor: '#0D9488' } : {}}
                onClick={() => {
                  if (item.children) toggleExpand(item.href)
                  else router.push(item.href)
                }}
              >
                <span className={isActive ? 'text-white' : 'text-slate-400'}>{item.icon}</span>
                <span className="flex-1">{item.label}</span>
                {item.children && (
                  <svg className={`w-4 h-4 transition-transform ${isExpanded ? 'rotate-90' : ''}`} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7"/>
                  </svg>
                )}
              </div>
              {item.children && isExpanded && (
                <div className="ml-4 mb-1">
                  {item.children.map(child => (
                    <Link
                      key={child.href}
                      href={child.href}
                      className={`flex items-center gap-2 px-3 py-1.5 rounded-lg text-xs font-medium transition-colors mb-0.5 ${
                        pathname === child.href ? 'text-teal-700 bg-teal-50' : 'text-slate-500 hover:text-slate-700 hover:bg-slate-50'
                      }`}
                    >
                      <span className="w-1 h-1 rounded-full bg-current"/>
                      {child.label}
                    </Link>
                  ))}
                </div>
              )}
            </div>
          )
        })}
      </nav>

      <div className="p-3 border-t border-slate-100">
        <div className="flex items-center gap-2.5 px-2 py-2">
          <div className="w-8 h-8 rounded-full flex items-center justify-center text-white text-sm font-bold flex-shrink-0" style={{ backgroundColor: '#0D9488' }}>
            {userName.charAt(0).toUpperCase() || 'U'}
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-xs font-semibold text-slate-800 truncate">{userName || 'Loading…'}</p>
            <p className="text-xs text-slate-400 capitalize">{role?.replace('_', ' ') || ''}</p>
          </div>
          <button onClick={handleSignOut} className="p-1.5 rounded-md text-slate-400 hover:text-slate-600 hover:bg-slate-100 transition-colors" title="Sign out">
            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/>
            </svg>
          </button>
        </div>
      </div>
    </div>
  )
}
