export function SkeletonText({ className = '' }: { className?: string }) {
  return <div className={`h-4 bg-slate-200 rounded animate-pulse ${className}`}/>
}
export function SkeletonCard({ className = '' }: { className?: string }) {
  return <div className={`bg-white rounded-xl border border-slate-200 p-6 space-y-3 ${className}`}>
    <SkeletonText className="w-1/3 h-5"/>
    <SkeletonText className="w-2/3"/>
    <SkeletonText className="w-1/2"/>
  </div>
}
export function SkeletonTable({ rows = 5 }: { rows?: number }) {
  return <div className="space-y-2">
    <div className="h-10 bg-slate-100 rounded-lg animate-pulse"/>
    {Array.from({ length: rows }).map((_, i) => (
      <div key={i} className="h-14 bg-white border border-slate-100 rounded-lg animate-pulse"/>
    ))}
  </div>
}
