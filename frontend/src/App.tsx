import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom'

import { Layout } from './components/Layout'
import { RequireAuth } from './components/RequireAuth'
import { useAuth } from './auth/AuthContext'
import { ForgotPage } from './pages/ForgotPage'
import { HomePage } from './pages/HomePage'
import { LandingPage } from './pages/LandingPage'
import { LoginPage } from './pages/LoginPage'
import { ReceivePage } from './pages/ReceivePage'
import { RegisterPage } from './pages/RegisterPage'
import { SendPage } from './pages/SendPage'
import { SettingsPage } from './pages/SettingsPage'

function IndexRoute() {
  const auth = useAuth()

  if (auth.isLoading) {
    return (
      <div className="center" style={{ padding: 32 }}>
        Yükleniyor...
      </div>
    )
  }

  if (auth.accessToken) {
    return <Navigate to="/home" replace />
  }

  return <LandingPage />
}

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route element={<Layout />}>
          <Route path="/" element={<IndexRoute />} />

          <Route path="/login" element={<LoginPage />} />
          <Route path="/register" element={<RegisterPage />} />
          <Route path="/forgot" element={<ForgotPage />} />

          <Route
            path="/home"
            element={
              <RequireAuth>
                <HomePage />
              </RequireAuth>
            }
          />
          <Route
            path="/send"
            element={
              <RequireAuth>
                <SendPage />
              </RequireAuth>
            }
          />
          <Route
            path="/receive"
            element={
              <RequireAuth>
                <ReceivePage />
              </RequireAuth>
            }
          />
          <Route
            path="/settings"
            element={
              <RequireAuth>
                <SettingsPage />
              </RequireAuth>
            }
          />

          <Route path="*" element={<Navigate to="/" replace />} />
        </Route>
      </Routes>
    </BrowserRouter>
  )
}
