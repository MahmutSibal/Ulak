import { Link } from 'react-router-dom'

export function LandingPage() {
  return (
    <div className="page">
      <section className="hero">
        <div className="hero__content">
          <div className="hero__brand">
            <img className="logo logo-lg" src="/logo.png" alt="Ulak" />
            <h1 className="hero__title">Ulak</h1>
          </div>
          <p className="hero__subtitle">
            Çoklu platform destekli, oturum bazlı dosya gönderme/alma.
            <br />
            Giriş yapmadan sistemi tanıyın; giriş yaptığınızda transfer ekranlarına geçin.
          </p>

          <div className="hero__actions">
            <Link className="btn btn-primary" to="/login">
              Giriş Yap
            </Link>
            <Link className="btn btn-ghost" to="/register">
              Kayıt Ol
            </Link>
          </div>

          <div className="hero__meta">
            <div className="pill">JWT + SQL Server</div>
            <div className="pill">Transfer oturumu + upload/download</div>
            <div className="pill">LAN erişimi (Vite)</div>
          </div>
        </div>

        <div className="hero__panel">
          <div className="card">
            <div className="card__title">Hızlı Başlangıç</div>
            <ol className="list">
              <li>Giriş yap veya kayıt ol.</li>
              <li>"Dosya Ver" ile transferi başlatıp dosyayı yükle.</li>
              <li>Alıcı "Dosya Al" ekranından kabul edip indir.</li>
            </ol>
          </div>
        </div>
      </section>

      <section className="grid">
        <div className="card">
          <div className="card__title">Basit akış</div>
          <div className="muted">Gönder → Kabul → İndir</div>
        </div>
        <div className="card">
          <div className="card__title">Kontroller</div>
          <div className="muted">Boyut + SHA-256 checksum doğrulaması</div>
        </div>
        <div className="card">
          <div className="card__title">Kayıt</div>
          <div className="muted">Oturum ve transfer logları</div>
        </div>
      </section>

      <div className="footer-note muted">
        Devam etmek için <Link to="/login">giriş</Link> yapın.
      </div>
    </div>
  )
}
