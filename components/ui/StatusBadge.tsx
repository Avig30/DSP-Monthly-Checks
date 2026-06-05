import Badge from './Badge'

const STATUS_MAP: Record<string, { color: 'green'|'amber'|'red'|'gray'|'blue'|'purple'; label?: string }> = {
  active: { color: 'green' }, complete: { color: 'green' }, clear: { color: 'green' }, approved: { color: 'green' }, strong: { color: 'green' },
  pending: { color: 'amber' }, expiring: { color: 'amber' }, warning: { color: 'amber' }, warm: { color: 'amber' }, submitted: { color: 'amber' }, supervisor_review: { color: 'amber', label: 'In Review' },
  expired: { color: 'red' }, flagged: { color: 'red' }, critical: { color: 'red' }, match: { color: 'red' }, terminated: { color: 'red' }, exceeded: { color: 'red' }, update_required: { color: 'red', label: 'Update Required' },
  inactive: { color: 'gray' }, not_started: { color: 'gray', label: 'Not Started' }, rejected: { color: 'gray' }, new: { color: 'gray' }, draft: { color: 'gray' },
  in_progress: { color: 'blue', label: 'In Progress' }, onboarding: { color: 'blue' }, staffing_needed: { color: 'amber', label: 'Staffing Needed' },
  admin: { color: 'purple' }, bcba: { color: 'purple' },
}

export default function StatusBadge({ status }: { status: string }) {
  const config = STATUS_MAP[status] || { color: 'gray' as const }
  return <Badge color={config.color}>{config.label || status.replace(/_/g, ' ')}</Badge>
}
