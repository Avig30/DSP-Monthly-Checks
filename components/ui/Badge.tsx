type Color = 'green' | 'amber' | 'red' | 'gray' | 'blue' | 'purple'
interface BadgeProps { color?: Color; children: React.ReactNode; className?: string }

const colors: Record<Color, string> = {
  green: 'bg-green-100 text-green-700',
  amber: 'bg-amber-100 text-amber-700',
  red: 'bg-red-100 text-red-700',
  gray: 'bg-slate-100 text-slate-600',
  blue: 'bg-blue-100 text-blue-700',
  purple: 'bg-purple-100 text-purple-700',
}

export default function Badge({ color = 'gray', children, className = '' }: BadgeProps) {
  return (
    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${colors[color]} ${className}`}>
      {children}
    </span>
  )
}
