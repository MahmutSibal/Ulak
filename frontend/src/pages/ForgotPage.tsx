import { useState, type FormEvent } from 'react'
import { Link } from 'react-router-dom'

import { useAuth } from '../auth/AuthContext'

export function ForgotPage() {
  const auth = useAuth()

  const [email, setEmail] = useState('')
  const [question, setQuestion] = useState<string | null>(null)
  const [answer, setAnswer] = useState('')
  const [newPassword, setNewPassword] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)

  async function getQuestion(e: FormEvent) {
    e.preventDefault()
    setError(null)
    setNewPassword(null)

    try {
      const q = await auth.forgotQuestion(email.trim())
      if (!q) throw new Error('no question')
      setQuestion(q)
    } catch {
      setError('Kullanıcı bulunamadı veya hata oluştu.')
    }
  }

  async function reset(e: FormEvent) {
    e.preventDefault()
    setError(null)
    setNewPassword(null)

    try {
      const pw = await auth.forgotReset(email.trim(), answer.trim())
      if (!pw) throw new Error('no pw')
      setNewPassword(pw)
    } catch {
      setError('Cevap hatalı veya işlem başarısız.')
    }
  }

  return (
    <div className="page">
      <div className="card" style={{ maxWidth: 720, margin: '0 auto' }}>
        <div className="card__title">Şifremi Unuttum</div>
        <div className="muted">Güvenlik sorusu ile geçici yeni şifre üretin.</div>

        {!question ? (
          <form onSubmit={getQuestion} className="form" style={{ marginTop: 14 }}>
            <label>
              E-posta
              <input value={email} onChange={(e) => setEmail(e.target.value)} type="email" required />
            </label>
            <button className="btn btn-primary" type="submit">
              Güvenlik sorusunu getir
            </button>
          </form>
        ) : (
          <form onSubmit={reset} className="form" style={{ marginTop: 14 }}>
            <div className="alert">
              <strong>Soru:</strong> {question}
            </div>
            <label>
              Cevap
              <input value={answer} onChange={(e) => setAnswer(e.target.value)} required />
            </label>
            <button className="btn btn-primary" type="submit">
              Yeni şifre üret
            </button>
          </form>
        )}

        {newPassword ? (
          <div className="alert alert--success" style={{ marginTop: 12 }}>
            <div>
              <strong>Yeni şifreniz:</strong> <code>{newPassword}</code>
            </div>
            <div className="muted">İlk girişte şifre değiştirmeniz istenir.</div>
          </div>
        ) : null}

        {error ? (
          <div className="alert alert--danger" style={{ marginTop: 12 }}>
            {error}
          </div>
        ) : null}

        <div style={{ marginTop: 12 }}>
          <Link className="btn btn-ghost" to="/login">
            Giriş sayfasına dön
          </Link>
        </div>
      </div>
    </div>
  )
}
