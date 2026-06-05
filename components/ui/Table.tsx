'use client'
import { useState, useMemo } from 'react'
import { SkeletonTable } from './Skeleton'
import EmptyState from './EmptyState'

export interface Column<T> {
  id: string
  header: string
  cell: (row: T) => React.ReactNode
  sortable?: boolean
  sortValue?: (row: T) => string | number
}

interface TableProps<T> {
  columns: Column<T>[]
  data: T[]
  onRowClick?: (row: T) => void
  loading?: boolean
  emptyTitle?: string
  emptyDescription?: string
  searchPlaceholder?: string
  searchFn?: (row: T, query: string) => boolean
}

export default function Table<T>({ columns, data, onRowClick, loading, emptyTitle = 'No results', emptyDescription, searchPlaceholder = 'Search…', searchFn }: TableProps<T>) {
  const [query, setQuery] = useState('')
  const [sortCol, setSortCol] = useState<string | null>(null)
  const [sortDir, setSortDir] = useState<'asc' | 'desc'>('asc')

  const filtered = useMemo(() => {
    let rows = data
    if (query && searchFn) rows = rows.filter(r => searchFn(r, query.toLowerCase()))
    if (sortCol) {
      const col = columns.find(c => c.id === sortCol)
      if (col?.sortValue) {
        rows = [...rows].sort((a, b) => {
          const av = col.sortValue!(a), bv = col.sortValue!(b)
          return sortDir === 'asc' ? (av < bv ? -1 : av > bv ? 1 : 0) : (av > bv ? -1 : av < bv ? 1 : 0)
        })
      }
    }
    return rows
  }, [data, query, sortCol, sortDir, columns, searchFn])

  function handleSort(id: string) {
    if (sortCol === id) setSortDir(d => d === 'asc' ? 'desc' : 'asc')
    else { setSortCol(id); setSortDir('asc') }
  }

  if (loading) return <SkeletonTable/>

  return (
    <div className="space-y-3">
      {searchFn && (
        <div className="flex justify-end">
          <div className="relative">
            <svg className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>
            <input value={query} onChange={e => setQuery(e.target.value)} placeholder={searchPlaceholder} className="pl-9 pr-4 py-2 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-teal-500 w-64"/>
          </div>
        </div>
      )}
      <div className="bg-white rounded-xl border border-slate-200 overflow-hidden">
        <table className="w-full">
          <thead>
            <tr className="border-b border-slate-200 bg-slate-50">
              {columns.map(col => (
                <th key={col.id} className={`px-4 py-3 text-left text-xs font-semibold text-slate-500 uppercase tracking-wide ${col.sortable ? 'cursor-pointer hover:text-slate-700 select-none' : ''}`}
                  onClick={() => col.sortable && handleSort(col.id)}>
                  <span className="flex items-center gap-1">
                    {col.header}
                    {col.sortable && sortCol === col.id && <span>{sortDir === 'asc' ? '↑' : '↓'}</span>}
                  </span>
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {filtered.length === 0 ? (
              <tr><td colSpan={columns.length}><EmptyState icon="📭" title={emptyTitle} description={emptyDescription}/></td></tr>
            ) : (
              filtered.map((row, i) => (
                <tr key={i} onClick={() => onRowClick?.(row)}
                  className={`border-b border-slate-100 last:border-0 transition-colors ${onRowClick ? 'cursor-pointer hover:bg-slate-50' : ''}`}>
                  {columns.map(col => <td key={col.id} className="px-4 py-3 text-sm text-slate-700">{col.cell(row)}</td>)}
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
      {filtered.length > 0 && <p className="text-xs text-slate-400 text-right">{filtered.length} record{filtered.length !== 1 ? 's' : ''}</p>}
    </div>
  )
}
