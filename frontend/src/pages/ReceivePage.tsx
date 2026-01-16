import { useEffect, useMemo, useState } from 'react'

import { api, downloadTransfer } from '../api/client'
import { useAuth } from '../auth/AuthContext'

type TransferSession = {
  id: string
  receiver_user_id: string | null
  file_name: string
  file_size: number
  status: string
}

export function ReceivePage() {
  const auth = useAuth()
  const [items, setItems] = useState<TransferSession[]>([])
  const [error, setError] = useState<string | null>(null)

  async function load() {
    setError(null)
    try {
      const res = await api.get('/api/transfers/sessions', { params: { limit: 200, offset: 0 } })
      setItems(res.data as TransferSession[])
    } catch {
      setError('Transfer listesi alınamadı.')
    }
  }

  useEffect(() => {
    void load()
  }, [])

  const pending = useMemo(() => {
    if (!auth.userId) return []
    return items.filter((t) => t.status === 'pending' && t.receiver_user_id === auth.userId)
  }, [items, auth.userId])

  const accepted = useMemo(() => {
    if (!auth.userId) return []
    return items.filter((t) => (t.status === 'accepted' || t.status === 'completed') && t.receiver_user_id === auth.userId)
  }, [items, auth.userId])

  const completedCount = useMemo(() => accepted.filter((t) => t.status === 'completed').length, [accepted])

  async function accept(id: string) {
    await api.post(`/api/transfers/sessions/${id}/accept`)
    await load()
  }

  async function reject(id: string) {
    await api.post(`/api/transfers/sessions/${id}/reject`)
    await load()
  }

  return (
    <div className="page">
      <div className="card">
        <div style={{ display: 'flex', alignItems: 'center', gap: 12, flexWrap: 'wrap' }}>
          <div>
            <div className="card__title">Dosya Al</div>
            <div className="muted">Bekleyen transferleri yönetin ve indirin.</div>
          </div>
          <div className="spacer" />
          <button className="btn btn-ghost" onClick={() => void load()}>
            Yenile
          </button>
        </div>

        <div className="kpi" style={{ marginTop: 12 }}>
          <div className="card card--subtle card--flat">
            <div className="kpi__label">Bekleyen (benim)</div>
            <div className="kpi__value">{pending.length}</div>
            <div className="kpi__hint">Kabul/Reddet bekliyor</div>
          </div>
          <div className="card card--subtle card--flat">
            <div className="kpi__label">Kabul edilen</div>
            <div className="kpi__value">{accepted.length}</div>
            <div className="kpi__hint">accepted + completed</div>
          </div>
          <div className="card card--subtle card--flat">
            <div className="kpi__label">Tamamlanan</div>
            <div className="kpi__value">{completedCount}</div>
            <div className="kpi__hint">İndirmeye hazır</div>
          </div>
          <div className="card card--subtle card--flat">
            <div className="kpi__label">İpucu</div>
            <div className="kpi__value">İndir</div>
            <div className="kpi__hint">Kabul ettikten sonra indir</div>
          </div>
        </div>

        {error ? (
          <div className="alert alert--danger" style={{ marginTop: 12 }}>
            {error}
          </div>
        ) : null}

        {pending.length === 0 && accepted.length === 0 ? (
          <div className="alert" style={{ marginTop: 12 }}>
            <div style={{ fontWeight: 800 }}>Henüz gelen transfer yok</div>
            <div className="muted" style={{ marginTop: 4 }}>
              Gönderici, transfer oluşturup dosyayı yükledikten sonra burada görünür.
            </div>
          </div>
        ) : null}

        <div style={{ marginTop: 12 }}>
          <div className="card__title">Bekleyen İstekler</div>
          {pending.length === 0 ? (
            <div className="muted">Bekleyen transfer isteği yok.</div>
          ) : (
            <div style={{ display: 'grid', gap: 10, marginTop: 10 }}>
              {pending.map((t) => (
                <div key={t.id} className="card" style={{ background: 'rgba(255,255,255,0.04)' }}>
                  <div style={{ display: 'flex', gap: 12, flexWrap: 'wrap', alignItems: 'baseline' }}>
                    <strong>{t.file_name}</strong>
                    <span className="muted">{t.file_size} bytes</span>
                    <span className="pill">pending</span>
                  </div>
                  <div className="row" style={{ marginTop: 10 }}>
                    <button className="btn btn-danger" onClick={() => void reject(t.id)}>
                      Reddet
                    </button>
                    <button className="btn btn-primary" onClick={() => void accept(t.id)}>
                      Kabul
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        <div style={{ marginTop: 18 }}>
          <div className="card__title">Kabul Edilenler</div>
          {accepted.length === 0 ? (
            <div className="muted">Kabul edilen transfer yok.</div>
          ) : (
            <div style={{ display: 'grid', gap: 10, marginTop: 10 }}>
              {accepted.map((t) => (
                <div key={t.id} className="card" style={{ background: 'rgba(255,255,255,0.04)' }}>
                  <div style={{ display: 'flex', gap: 12, flexWrap: 'wrap', alignItems: 'baseline' }}>
                    <strong>{t.file_name}</strong>
                    <span className="muted">{t.file_size} bytes</span>
                    <span className="pill">{t.status}</span>
                  </div>
                  <div style={{ marginTop: 10 }}>
                    <button className="btn btn-primary" onClick={() => void downloadTransfer(t.id, t.file_name)}>
                      İndir
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
