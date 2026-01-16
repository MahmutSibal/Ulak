import { Link, NavLink, Outlet } from 'react-router-dom'

import { useAuth } from '../auth/AuthContext'

export function Layout() {
  const auth = useAuth()

  return (
    <div className="app-shell">
      <div className="app-container">
        <header className="app-header">
          <Link to="/" className="brand brand-link">
            <img className="logo" src="/logo.png" alt="Ulak" />
            <span>Ulak</span>
          </Link>

          {auth.accessToken ? (
            <nav className="nav">
              <NavLink to="/home">Anasayfa</NavLink>
              <NavLink to="/send">Dosya Ver</NavLink>
              <NavLink to="/receive">Dosya Al</NavLink>
              <NavLink to="/settings">Ayarlar</NavLink>
            </nav>
          ) : (
            <div className="muted">Güvenli dosya transferi</div>
          )}

          <div className="spacer" />

          {auth.accessToken ? (
            <>
              <span className="pill">User: {auth.userId ?? '-'}</span>
              <button className="btn btn-danger" onClick={auth.logout}>
                Çıkış
              </button>
            </>
          ) : (
            <>
              <Link className="btn btn-ghost" to="/login">
                Giriş
              </Link>
              <Link className="btn btn-primary" to="/register">
                Kayıt Ol
              </Link>
            </>
          )}
        </header>

        <Outlet />
      </div>
    </div>
  )
}
