import { Navigate, useLocation } from 'react-router-dom'
import type { ReactElement } from 'react'

import { useAuth } from '../auth/AuthContext'

export function RequireAuth({ children }: { children: ReactElement }) {
  const auth = useAuth()
  const location = useLocation()

  if (auth.isLoading) return <div>Yükleniyor...</div>

  if (!auth.accessToken) {
    return <Navigate to="/login" replace state={{ from: location.pathname }} />
  }

  if (auth.mustChangePassword && location.pathname !== '/settings') {
    return <Navigate to="/settings" replace />
  }

  return children
}
