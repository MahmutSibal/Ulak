import { useState, type FormEvent } from 'react'
import { Link, useNavigate } from 'react-router-dom'

import { useAuth } from '../auth/AuthContext'

export function LoginPage() {
  const auth = useAuth()
  const nav = useNavigate()

  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState<string | null>(null)

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setError(null)

    try {
      await auth.login(email.trim(), password)
      nav('/')
    } catch (err) {
      setError('Giriş başarısız. E-posta/şifre kontrol edin.')
    }
  }

  return (
    <div className="page">
      <div className="card" style={{ maxWidth: 520, margin: '0 auto' }}>
        <div className="card__title">Giriş</div>
        <div className="muted">Hesabınıza giriş yapıp transfer ekranlarına geçin.</div>

        <form onSubmit={onSubmit} className="form" style={{ marginTop: 14 }}>
          <label>
            E-posta
            <input value={email} onChange={(e) => setEmail(e.target.value)} type="email" required />
          </label>
          <label>
            Şifre (6 hane)
            <input value={password} onChange={(e) => setPassword(e.target.value)} type="password" required />
          </label>

          {error ? <div className="alert alert--danger">{error}</div> : null}

          <div className="row">
            <button className="btn btn-primary" type="submit">
              Giriş Yap
            </button>
            <Link className="btn btn-ghost" to="/register">
              Kayıt Ol
            </Link>
          </div>
        </form>

        <div style={{ marginTop: 12 }} className="muted">
          Şifrenizi unuttuysanız: <Link to="/forgot">Şifremi Unuttum</Link>
        </div>
      </div>
    </div>
  )
}
