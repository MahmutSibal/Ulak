import { useMemo, useState, type FormEvent } from 'react'

import { api } from '../api/client'
import { sha256Hex } from '../utils/sha256'

function formatBytes(bytes: number) {
  if (!Number.isFinite(bytes) || bytes <= 0) return '0 B'
  const units = ['B', 'KB', 'MB', 'GB', 'TB']
  const i = Math.min(units.length - 1, Math.floor(Math.log(bytes) / Math.log(1024)))
  const v = bytes / Math.pow(1024, i)
  const fixed = v >= 100 ? 0 : v >= 10 ? 1 : 2
  return `${v.toFixed(fixed)} ${units[i]}`
}

export function SendPage() {
  const [receiverIp, setReceiverIp] = useState('')
  const [receiverUserId, setReceiverUserId] = useState('')
  const [files, setFiles] = useState<File[]>([])
  const [error, setError] = useState<string | null>(null)
  const [info, setInfo] = useState<string | null>(null)
  const [sending, setSending] = useState(false)

  const totalSize = useMemo(() => files.reduce((sum, f) => sum + (f.size || 0), 0), [files])

  const recipientMode = useMemo(() => {
    const ip = receiverIp.trim()
    const uid = receiverUserId.trim()
    if (uid) return 'uid'
    if (ip) return 'ip'
    return 'none'
  }, [receiverIp, receiverUserId])

  function removeFile(idx: number) {
    setFiles((prev) => prev.filter((_, i) => i !== idx))
  }

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setError(null)
    setInfo(null)

    const ip = receiverIp.trim() || null
    const uid = receiverUserId.trim() || null

    if (!ip && !uid) {
      setError('Alıcı IP veya Kullanıcı ID girin.')
      return
    }

    if (files.length === 0) {
      setError('En az 1 dosya seçmelisiniz.')
      return
    }

    setSending(true)
    try {
      for (const f of files) {
        const buf = await f.arrayBuffer()
        const checksum = await sha256Hex(buf)

        const created = await api.post('/api/transfers/sessions', {
          receiver_ip: ip,
          receiver_user_id: uid,
          file_name: f.name,
          file_size: f.size,
          file_type: f.type || null,
          checksum_sha256: checksum,
        })

        const transferId = String((created.data as any)?.id)
        if (!transferId) throw new Error('transfer id missing')

        const form = new FormData()
        form.append('file', f, f.name)

        await api.post(`/api/transfers/sessions/${transferId}/upload`, form)
      }

      setInfo('Transfer oturumu oluşturuldu ve dosya yüklendi.')
    } catch (e) {
      setError('Transfer başlatılamadı.')
    } finally {
      setSending(false)
    }
  }

  return (
    <div className="page">
      <div className="card">
        <div className="card__title">Dosya Ver</div>
        <div className="muted">Transfer oturumu oluşturup dosyayı yükleyin.</div>

        <div className="kpi" style={{ marginTop: 12 }}>
          <div className="card card--subtle card--flat">
            <div className="kpi__label">Seçili dosya</div>
            <div className="kpi__value">{files.length}</div>
            <div className="kpi__hint">Toplam boyut: {formatBytes(totalSize)}</div>
          </div>
          <div className="card card--subtle card--flat">
            <div className="kpi__label">Alıcı modu</div>
            <div className="kpi__value">
              {recipientMode === 'uid' ? 'Kullanıcı ID' : recipientMode === 'ip' ? 'IP' : '-'}
            </div>
            <div className="kpi__hint">IP veya UUID ile hedefle</div>
          </div>
          <div className="card card--subtle card--flat">
            <div className="kpi__label">Checksum</div>
            <div className="kpi__value">SHA-256</div>
            <div className="kpi__hint">İstemcide hesaplanır</div>
          </div>
          <div className="card card--subtle card--flat">
            <div className="kpi__label">İpucu</div>
            <div className="kpi__value">LAN</div>
            <div className="kpi__hint">Telefon tarayıcısından da çalışır</div>
          </div>
        </div>

        <form onSubmit={onSubmit} className="form" style={{ marginTop: 14, maxWidth: 920 }}>
          <div className="row">
            <label>
            IP (opsiyonel)
            <input value={receiverIp} onChange={(e) => setReceiverIp(e.target.value)} placeholder="192.168.1.100" />
            </label>
            <label>
            Kullanıcı ID (UUID) (opsiyonel)
            <input
              value={receiverUserId}
              onChange={(e) => setReceiverUserId(e.target.value)}
              placeholder="3fa85f64-5717-4562-b3fc-2c963f66afa6"
            />
            </label>
          </div>

          {recipientMode === 'none' ? (
            <div className="alert alert--warn">
              Alıcıyı hedeflemek için <strong>IP</strong> veya <strong>Kullanıcı ID</strong> girin.
            </div>
          ) : null}

          <label>
            Dosya seç
            <input
              type="file"
              multiple
              onChange={(e) => setFiles(Array.from(e.target.files ?? []))}
              disabled={sending}
            />
          </label>

          {files.length ? (
            <div className="card card--subtle card--flat">
              <div className="muted" style={{ marginBottom: 8 }}>
                Seçilen dosyalar
              </div>
              <div style={{ display: 'grid', gap: 8 }}>
                {files.map((f, idx) => (
                  <div
                    key={f.name + f.size + idx}
                    className="card card--flat"
                    style={{ padding: 12, background: 'rgba(255,255,255,0.04)' }}
                  >
                    <div style={{ display: 'flex', gap: 10, alignItems: 'center' }}>
                      <div style={{ minWidth: 0, flex: 1 }}>
                        <div className="truncate" style={{ fontWeight: 800 }}>
                          {f.name}
                        </div>
                        <div className="muted" style={{ fontSize: 12 }}>
                          {formatBytes(f.size)}
                        </div>
                      </div>
                      <button className="btn btn-danger" type="button" onClick={() => removeFile(idx)} disabled={sending}>
                        Kaldır
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          ) : (
            <div className="muted">Henüz dosya seçilmedi.</div>
          )}

          {error ? <div className="alert alert--danger">{error}</div> : null}
          {info ? <div className="alert alert--success">{info}</div> : null}

          <button className="btn btn-primary" type="submit" disabled={sending}>
            {sending ? 'Gönderiliyor...' : 'Transfer Başlat'}
          </button>
        </form>
      </div>
    </div>
  )
}
