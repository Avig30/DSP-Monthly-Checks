interface EmptyStateProps { icon?: React.ReactNode; title: string; description?: string; action?: { label: string; onClick: () => void } }
export default function EmptyState({ icon, title, description, action }: EmptyStateProps) {
  return (
    <div className="flex flex-col items-center justify-center py-16 text-center">
      {icon && <div className="text-5xl mb-4 opacity-40">{icon}</div>}
      <h3 className="text-base font-semibold text-slate-700 mb-1">{title}</h3>
      {description && <p className="text-sm text-slate-400 max-w-xs">{description}</p>}
      {action && (
        <button onClick={action.onClick} className="mt-4 px-4 py-2 rounded-lg text-sm font-medium text-white hover:opacity-90 transition-opacity" style={{ backgroundColor: '#0D9488' }}>
          {action.label}
        </button>
      )}
    </div>
  )
}
