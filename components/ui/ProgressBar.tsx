interface ProgressBarProps { value: number; showLabel?: boolean; height?: string; className?: string }

export default function ProgressBar({ value, showLabel = false, height = 'h-2', className = '' }: ProgressBarProps) {
  const clamped = Math.min(100, Math.max(0, value))
  const color = clamped >= 90 ? 'bg-red-500' : clamped >= 75 ? 'bg-amber-500' : 'bg-green-500'
  return (
    <div className={`flex items-center gap-2 ${className}`}>
      <div className={`flex-1 bg-slate-200 rounded-full overflow-hidden ${height}`}>
        <div className={`${height} ${color} rounded-full transition-all duration-300`} style={{ width: `${clamped}%` }}/>
      </div>
      {showLabel && <span className="text-xs font-medium text-slate-600 w-8 text-right">{clamped}%</span>}
    </div>
  )
}
