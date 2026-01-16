import { useEffect, useMemo, useState } from 'react'
import { Link } from 'react-router-dom'

import { api } from '../api/client'
import { useAuth } from '../auth/AuthContext'

type TransferSession = {
  id: string
  file_name: string
  file_size: number
  status: string
  created_at: string
  receiver_user_id?: string | null
}

function formatBytes(bytes: number) {
  if (!Number.isFinite(bytes) || bytes <= 0) return '0 B'
  const units = ['B', 'KB', 'MB', 'GB', 'TB']
  const i = Math.min(units.length - 1, Math.floor(Math.log(bytes) / Math.log(1024)))
  const v = bytes / Math.pow(1024, i)
  const fixed = v >= 100 ? 0 : v >= 10 ? 1 : 2
  return `${v.toFixed(fixed)} ${units[i]}`
}

function statusClass(status: string) {
  const s = String(status || '').toLowerCase()
  if (s === 'pending') return 'status status--pending'
  if (s === 'accepted') return 'status status--accepted'
  if (s === 'completed') return 'status status--completed'
  if (s === 'rejected') return 'status status--rejected'
  return 'status'
}

export function HomePage() {
  const auth = useAuth()
  const [items, setItems] = useState<TransferSession[]>([])
  const [error, setError] = useState<string | null>(null)

  async function load() {
    setError(null)
    try {
      const res = await api.get('/api/transfers/sessions', { params: { limit: 50, offset: 0 } })
      setItems(res.data as TransferSession[])
    } catch (e) {
      setError('Transfer listesi alınamadı.')
    }
  }

  useEffect(() => {
    void load()
  }, [])

  const stats = useMemo(() => {
    const byStatus = new Map<string, number>()
    let totalBytes = 0
    let pendingMine = 0

    for (const t of items) {
      const s = String(t.status || 'unknown').toLowerCase()
      byStatus.set(s, (byStatus.get(s) ?? 0) + 1)
      totalBytes += Number(t.file_size) || 0

      if (auth.userId && s === 'pending' && String(t.receiver_user_id ?? '') === auth.userId) {
        pendingMine += 1
      }
    }

    return {
      total: items.length,
      totalBytes,
      pending: byStatus.get('pending') ?? 0,
      accepted: byStatus.get('accepted') ?? 0,
      completed: byStatus.get('completed') ?? 0,
      rejected: byStatus.get('rejected') ?? 0,
      pendingMine,
    }
  }, [items, auth.userId])

  const recent = useMemo(() => {
    const sorted = [...items].sort((a, b) => {
      const at = new Date(a.created_at).getTime()
      const bt = new Date(b.created_at).getTime()
      return bt - at
    })
    return sorted.slice(0, 8)
  }, [items])

  return (
    <div className="page">
      <div className="section-header">
        <div>
          <div className="card__title" style={{ marginBottom: 2 }}>
            Hoş geldin
          </div>
          <div className="muted">
            Hesap: <span className="mono">{auth.userId ?? '-'}</span>
          </div>
        </div>
        <div className="spacer" />
        <div className="section-actions">
          <button className="btn btn-ghost" onClick={() => void load()}>
            Yenile
          </button>
          <Link className="btn btn-primary" to="/send">
            Dosya Ver
          </Link>
          <Link className="btn btn-ghost" to="/receive">
            Dosya Al
          </Link>
        </div>
      </div>

      {error ? <div className="alert alert--danger">{error}</div> : null}

      <div className="kpi" style={{ marginTop: 12 }}>
        <div className="card card--subtle">
          <div className="kpi__label">Toplam oturum</div>
          <div className="kpi__value">{stats.total}</div>
          <div className="kpi__hint">Son {Math.min(items.length, 50)} kayıttan</div>
        </div>
        <div className="card card--subtle">
          <div className="kpi__label">Toplam boyut</div>
          <div className="kpi__value">{formatBytes(stats.totalBytes)}</div>
          <div className="kpi__hint">Listelediğin oturumlara göre</div>
        </div>
        <div className="card card--subtle">
          <div className="kpi__label">Bekleyen (benim)</div>
          <div className="kpi__value">{stats.pendingMine}</div>
          <div className="kpi__hint">Alıcı sensen ve pending ise</div>
        </div>
        <div className="card card--subtle">
          <div className="kpi__label">Tamamlanan</div>
          <div className="kpi__value">{stats.completed}</div>
          <div className="kpi__hint">completed statüsündekiler</div>
        </div>
      </div>

      <div className="split" style={{ marginTop: 12 }}>
        <div className="card">
          <div className="section-header">
            <div>
              <div className="card__title" style={{ marginBottom: 2 }}>
                Hızlı işlemler
              </div>
              <div className="muted">Sık kullanılan ekranlara tek tık</div>
            </div>
          </div>

          <div className="actions-grid" style={{ marginTop: 12 }}>
            <Link className="action-tile" to="/send">
              <div className="action-tile__title">Dosya Gönder</div>
              <div className="action-tile__desc">Transfer oluştur + dosyayı yükle</div>
            </Link>
            <Link className="action-tile" to="/receive">
              <div className="action-tile__title">Gelenleri Yönet</div>
              <div className="action-tile__desc">Kabul et, indir, reddet</div>
            </Link>
            <Link className="action-tile" to="/settings">
              <div className="action-tile__title">Ayarlar</div>
              <div className="action-tile__desc">Şifre değiştir ve hesabını yönet</div>
            </Link>
          </div>
        </div>

        <div className="card">
          <div className="section-header">
            <div>
              <div className="card__title" style={{ marginBottom: 2 }}>
                Durum özeti
              </div>
              <div className="muted">Oturumların statülere göre dağılımı</div>
            </div>
          </div>

          <div style={{ marginTop: 12, display: 'grid', gap: 10 }}>
            <div className="card card--subtle card--flat">
              <div style={{ display: 'flex', gap: 10, flexWrap: 'wrap', alignItems: 'center' }}>
                <span className="status status--pending">pending</span>
                <span className="muted">{stats.pending} adet</span>
              </div>
            </div>
            <div className="card card--subtle card--flat">
              <div style={{ display: 'flex', gap: 10, flexWrap: 'wrap', alignItems: 'center' }}>
                <span className="status status--accepted">accepted</span>
                <span className="muted">{stats.accepted} adet</span>
              </div>
            </div>
            <div className="card card--subtle card--flat">
              <div style={{ display: 'flex', gap: 10, flexWrap: 'wrap', alignItems: 'center' }}>
                <span className="status status--completed">completed</span>
                <span className="muted">{stats.completed} adet</span>
              </div>
            </div>
            <div className="card card--subtle card--flat">
              <div style={{ display: 'flex', gap: 10, flexWrap: 'wrap', alignItems: 'center' }}>
                <span className="status status--rejected">rejected</span>
                <span className="muted">{stats.rejected} adet</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="card" style={{ marginTop: 12 }}>
        <div className="section-header">
          <div>
            <div className="card__title" style={{ marginBottom: 2 }}>
              Son transferler
            </div>
            <div className="muted">En yeni 8 oturum</div>
          </div>
          <div className="spacer" />
          <Link className="btn btn-ghost" to="/receive">
            Gelenler
          </Link>
        </div>

        <div style={{ marginTop: 12, display: 'grid', gap: 10 }}>
          {recent.length === 0 ? (
            <div className="muted">Henüz transfer yok.</div>
          ) : (
            recent.map((t) => (
              <div key={t.id} className="card card--subtle card--flat">
                <div style={{ display: 'flex', gap: 12, flexWrap: 'wrap', alignItems: 'center' }}>
                  <strong className="truncate" style={{ maxWidth: 420 }}>
                    {t.file_name}
                  </strong>
                  <span className={statusClass(t.status)}>{String(t.status)}</span>
                  <span className="muted">{formatBytes(t.file_size)}</span>
                  <span className="muted">{new Date(t.created_at).toLocaleString()}</span>
                </div>
                <div className="muted" style={{ marginTop: 6, fontSize: 12 }}>
                  <span className="mono">{t.id}</span>
                </div>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  )
}
