import { useState, type FormEvent } from 'react'
import { Link } from 'react-router-dom'

import { useAuth } from '../auth/AuthContext'

export function RegisterPage() {
  const auth = useAuth()

  const [firstName, setFirstName] = useState('')
  const [lastName, setLastName] = useState('')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [password2, setPassword2] = useState('')
  const [securityQuestion, setSecurityQuestion] = useState('İlk okul öğretmeninizin adı?')
  const [securityAnswer, setSecurityAnswer] = useState('')

  const [error, setError] = useState<string | null>(null)
  const [info, setInfo] = useState<string | null>(null)

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setError(null)
    setInfo(null)

    try {
      await auth.register({
        firstName,
        lastName,
        email,
        password,
        passwordConfirm: password2,
        securityQuestion,
        securityAnswer,
      })
      setInfo('Kayıt başarılı. Giriş yapabilirsiniz.')
    } catch {
      setError('Kayıt başarısız. E-posta kullanılıyor olabilir.')
    }
  }

  return (
    <div className="page">
      <div className="card" style={{ maxWidth: 720, margin: '0 auto' }}>
        <div className="card__title">Kayıt Ol</div>
        <div className="muted">Yeni hesap oluşturup dosya transferine başlayın.</div>

        <form onSubmit={onSubmit} className="form" style={{ marginTop: 14 }}>
          <div className="row">
            <label>
            Ad
            <input value={firstName} onChange={(e) => setFirstName(e.target.value)} required />
            </label>
            <label>
            Soyad
            <input value={lastName} onChange={(e) => setLastName(e.target.value)} required />
            </label>
          </div>
          <label>
          E-posta
          <input value={email} onChange={(e) => setEmail(e.target.value)} type="email" required />
          </label>
          <div className="row">
            <label>
            Şifre (6 hane)
            <input value={password} onChange={(e) => setPassword(e.target.value)} type="password" required />
            </label>
            <label>
            Şifre Tekrar
            <input value={password2} onChange={(e) => setPassword2(e.target.value)} type="password" required />
            </label>
          </div>
          <label>
          Güvenlik Sorusu
          <input value={securityQuestion} onChange={(e) => setSecurityQuestion(e.target.value)} required />
          </label>
          <label>
          Güvenlik Cevabı
          <input value={securityAnswer} onChange={(e) => setSecurityAnswer(e.target.value)} required />
          </label>

          {error ? <div className="alert alert--danger">{error}</div> : null}
          {info ? <div className="alert alert--success">{info}</div> : null}

          <div className="row">
            <button className="btn btn-primary" type="submit">
              Kayıt Ol
            </button>
            <Link className="btn btn-ghost" to="/login">
              Giriş sayfasına dön
            </Link>
          </div>
        </form>
      </div>
    </div>
  )
}
