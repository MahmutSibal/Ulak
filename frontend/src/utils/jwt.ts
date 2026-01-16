export function jwtSubject(token: string): string | null {
  const parts = token.split('.')
  if (parts.length !== 3) return null

  const payload = parts[1]
  const normalized = payload.replace(/-/g, '+').replace(/_/g, '/')
  const padded = normalized + '='.repeat((4 - (normalized.length % 4)) % 4)

  try {
    const json = JSON.parse(atob(padded))
    const sub = json?.sub
    return typeof sub === 'string' ? sub : null
  } catch {
    return null
  }
}
