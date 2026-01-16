import { useState, type FormEvent } from 'react'
import { Link } from 'react-router-dom'

import { useAuth } from '../auth/AuthContext'

export function SettingsPage() {
  const auth = useAuth()

  const [oldPassword, setOldPassword] = useState('')
  const [newPassword, setNewPassword] = useState('')
  const [newPassword2, setNewPassword2] = useState('')

  const [error, setError] = useState<string | null>(null)
  const [info, setInfo] = useState<string | null>(null)

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setError(null)
    setInfo(null)

    try {
      await auth.changePassword(oldPassword, newPassword, newPassword2)
      setInfo('Şifre güncellendi.')
      setOldPassword('')
      setNewPassword('')
      setNewPassword2('')
    } catch {
      setError('Şifre değiştirilemedi.')
    }
  }

  return (
    <div className="page">
      <div className="card" style={{ maxWidth: 720, margin: '0 auto' }}>
        <div className="card__title">Ayarlar</div>
        <div className="muted">Şifrenizi güvenli şekilde güncelleyin.</div>

        <div className="card card--subtle card--flat" style={{ marginTop: 12 }}>
          <div className="kpi__label">Hesap</div>
          <div className="mono" style={{ fontWeight: 800 }}>
            {auth.userId ?? '-'}
          </div>
        </div>

        {auth.mustChangePassword ? (
          <div className="alert alert--warn" style={{ marginTop: 12 }}>
            Devam etmek için şifrenizi değiştirin.
          </div>
        ) : null}

        <form onSubmit={onSubmit} className="form" style={{ marginTop: 14 }}>
          <label>
            Mevcut Şifre
            <input value={oldPassword} onChange={(e) => setOldPassword(e.target.value)} type="password" required />
          </label>
          <div className="row">
            <label>
              Yeni Şifre (6 hane)
              <input value={newPassword} onChange={(e) => setNewPassword(e.target.value)} type="password" required />
            </label>
            <label>
              Yeni Şifre Tekrar
              <input value={newPassword2} onChange={(e) => setNewPassword2(e.target.value)} type="password" required />
            </label>
          </div>

          {error ? <div className="alert alert--danger">{error}</div> : null}
          {info ? <div className="alert alert--success">{info}</div> : null}

          <button className="btn btn-primary" type="submit">
            Şifreyi Değiştir
          </button>
        </form>

        <div className="section-actions" style={{ marginTop: 14 }}>
          <Link className="btn btn-ghost" to="/home">
            Dashboard
          </Link>
          <Link className="btn btn-ghost" to="/send">
            Dosya Ver
          </Link>
          <Link className="btn btn-ghost" to="/receive">
            Dosya Al
          </Link>
        </div>
      </div>
    </div>
  )
}
