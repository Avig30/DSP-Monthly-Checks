import { createServerSupabaseClient } from '@/lib/supabase-server'

async function getStats(supabase: any, agencyId: string) {
  const [participants, employees, incidents, compliance] = await Promise.all([
    supabase.from('participants').select('id', { count: 'exact' }).eq('agency_id', agencyId).eq('status', 'active'),
    supabase.from('employees').select('id', { count: 'exact' }).eq('agency_id', agencyId).eq('status', 'active'),
    supabase.from('incidents').select('id', { count: 'exact' }).eq('agency_id', agencyId).eq('status', 'open'),
    supabase.from('compliance_items').select('id', { count: 'exact' }).eq('agency_id', agencyId).in('status', ['expired', 'flagged', 'not_started']),
  ])
  return {
    participants: participants.count || 0,
    employees: employees.count || 0,
    incidents: incidents.count || 0,
    complianceGaps: compliance.count || 0,
  }
}

export default async function DashboardPage() {
  const supabase = createServerSupabaseClient()
  const { data: { user } } = await supabase.auth.getUser()
  const { data: profile } = await supabase.from('user_profiles').select('agency_id,first_name').eq('id', user!.id).single()

  const stats = profile?.agency_id ? await getStats(supabase, profile.agency_id) : { participants: 0, employees: 0, incidents: 0, complianceGaps: 0 }

  const StatCard = ({ title, value, icon, color, sub }: { title: string; value: number; icon: string; color: string; sub?: string }) => (
    <div className={`bg-white rounded-xl border p-6 ${color === 'red' && value > 0 ? 'border-red-200 bg-red-50' : 'border-slate-200'}`}>
      <div className="flex items-center justify-between mb-3">
        <span className="text-2xl">{icon}</span>
        <span className={`text-3xl font-bold ${color === 'red' && value > 0 ? 'text-red-600' : 'text-slate-800'}`}>{value}</span>
      </div>
      <p className={`text-sm font-medium ${color === 'red' && value > 0 ? 'text-red-700' : 'text-slate-600'}`}>{title}</p>
      {sub && <p className="text-xs text-slate-400 mt-0.5">{sub}</p>}
    </div>
  )

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-slate-900">Welcome back{profile?.first_name ? `, ${profile.first_name}` : ''} 👋</h1>
        <p className="text-slate-500 text-sm mt-1">Here&apos;s what&apos;s happening at ASG Home Care today.</p>
      </div>

      {stats.complianceGaps > 0 && (
        <div className="bg-red-50 border border-red-200 rounded-xl p-4 flex items-center gap-3">
          <svg className="w-5 h-5 text-red-500 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20"><path fillRule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clipRule="evenodd"/></svg>
          <div className="flex-1">
            <p className="text-sm font-semibold text-red-800">{stats.complianceGaps} Compliance Gap{stats.complianceGaps > 1 ? 's' : ''} Require Attention</p>
            <p className="text-xs text-red-600">Active employees have expired or missing compliance items.</p>
          </div>
          <a href="/compliance" className="text-xs font-medium text-red-700 underline hover:no-underline">View →</a>
        </div>
      )}

      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard title="Active Participants" value={stats.participants} icon="👥" color="teal" sub="Currently enrolled"/>
        <StatCard title="Active DSPs" value={stats.employees} icon="🏥" color="teal" sub="Direct support staff"/>
        <StatCard title="Compliance Gaps" value={stats.complianceGaps} icon="⚠️" color="red" sub="Need resolution"/>
        <StatCard title="Open Incidents" value={stats.incidents} icon="📋" color="amber" sub="Awaiting review"/>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white rounded-xl border border-slate-200 p-6">
          <h2 className="text-base font-semibold text-slate-800 mb-4">Quick Actions</h2>
          <div className="grid grid-cols-2 gap-3">
            {[
              { label: 'Add Participant', href: '/participants', icon: '👤' },
              { label: 'New Referral', href: '/referrals', icon: '📨' },
              { label: 'Log Incident', href: '/incidents/new', icon: '🚨' },
              { label: 'New Service Note', href: '/service-notes/new', icon: '📝' },
              { label: 'HR Hiring', href: '/hr/hiring', icon: '💼' },
              { label: 'Compliance', href: '/compliance', icon: '✅' },
            ].map(action => (
              <a key={action.href} href={action.href} className="flex items-center gap-2.5 p-3 rounded-lg border border-slate-200 hover:border-teal-300 hover:bg-teal-50 transition-colors text-sm font-medium text-slate-700 hover:text-teal-700">
                <span>{action.icon}</span>
                {action.label}
              </a>
            ))}
          </div>
        </div>

        <div className="bg-white rounded-xl border border-slate-200 p-6">
          <h2 className="text-base font-semibold text-slate-800 mb-4">Getting Started</h2>
          <div className="space-y-3">
            {[
              { step: 1, label: 'Add your first participant', href: '/participants', done: stats.participants > 0 },
              { step: 2, label: 'Set up DSP employees', href: '/hr/hiring', done: stats.employees > 0 },
              { step: 3, label: 'Create authorizations', href: '/authorizations', done: false },
              { step: 4, label: 'Record your first service note', href: '/service-notes/new', done: false },
            ].map(item => (
              <a key={item.step} href={item.href} className="flex items-center gap-3 p-3 rounded-lg hover:bg-slate-50 transition-colors">
                <div className={`w-6 h-6 rounded-full flex items-center justify-center text-xs font-bold flex-shrink-0 ${item.done ? 'bg-green-100 text-green-700' : 'bg-slate-100 text-slate-500'}`}>
                  {item.done ? '✓' : item.step}
                </div>
                <span className={`text-sm ${item.done ? 'line-through text-slate-400' : 'text-slate-700'}`}>{item.label}</span>
              </a>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}
