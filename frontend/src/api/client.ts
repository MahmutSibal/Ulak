import axios from 'axios'

const tokenKey = 'ulak_access_token'

export function getAccessToken(): string | null {
  return localStorage.getItem(tokenKey)
}

export function setAccessToken(token: string | null) {
  if (!token) localStorage.removeItem(tokenKey)
  else localStorage.setItem(tokenKey, token)
}

export const api = axios.create({
  // Dev: Vite proxy handles /api -> http://localhost:8000 (baseURL = '')
  // Prod / different network: set VITE_API_BASE_URL, e.g. https://api.example.com
  baseURL: (import.meta as any).env?.VITE_API_BASE_URL ? String((import.meta as any).env.VITE_API_BASE_URL) : '',
  timeout: 30_000,
})

api.interceptors.request.use((config) => {
  const token = getAccessToken()
  if (token) {
    config.headers = config.headers ?? {}
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

export async function downloadTransfer(transferId: string, filename: string) {
  const res = await api.get(`/api/transfers/sessions/${transferId}/download`, {
    responseType: 'blob',
  })

  const blob = res.data as Blob
  const url = URL.createObjectURL(blob)
  try {
    const a = document.createElement('a')
    a.href = url
    a.download = filename
    a.rel = 'noopener'
    document.body.appendChild(a)
    a.click()
    a.remove()
  } finally {
    URL.revokeObjectURL(url)
  }
}
