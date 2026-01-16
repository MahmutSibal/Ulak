import React, { createContext, useCallback, useContext, useEffect, useMemo, useState } from 'react'

import { api, getAccessToken, setAccessToken } from '../api/client'
import { jwtSubject } from '../utils/jwt'

type AuthState = {
  isLoading: boolean
  accessToken: string | null
  userId: string | null
  mustChangePassword: boolean
}

type AuthContextValue = AuthState & {
  login: (email: string, password: string) => Promise<void>
  register: (payload: {
    firstName: string
    lastName: string
    email: string
    password: string
    passwordConfirm: string
    securityQuestion: string
    securityAnswer: string
  }) => Promise<void>
  logout: () => void
  forgotQuestion: (email: string) => Promise<string>
  forgotReset: (email: string, securityAnswer: string) => Promise<string>
  changePassword: (oldPassword: string, newPassword: string, newPasswordConfirm: string) => Promise<void>
}

const mustChangeKey = 'ulak_must_change_password'

const AuthContext = createContext<AuthContextValue | null>(null)

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [state, setState] = useState<AuthState>({
    isLoading: true,
    accessToken: null,
    userId: null,
    mustChangePassword: false,
  })

  useEffect(() => {
    const token = getAccessToken()
    const mustChange = localStorage.getItem(mustChangeKey) === 'true'
    setState({
      isLoading: false,
      accessToken: token,
      userId: token ? jwtSubject(token) : null,
      mustChangePassword: mustChange,
    })
  }, [])

  const login = useCallback(async (email: string, password: string) => {
    setState((s) => ({ ...s, isLoading: true }))
    try {
      const res = await api.post('/api/auth/login', { email, password })
      const token = res.data?.access_token as string
      const mustChange = Boolean(res.data?.must_change_password)

      setAccessToken(token)
      localStorage.setItem(mustChangeKey, String(mustChange))

      setState({
        isLoading: false,
        accessToken: token,
        userId: jwtSubject(token),
        mustChangePassword: mustChange,
      })
    } finally {
      setState((s) => ({ ...s, isLoading: false }))
    }
  }, [])

  const register = useCallback(
    async (payload: {
      firstName: string
      lastName: string
      email: string
      password: string
      passwordConfirm: string
      securityQuestion: string
      securityAnswer: string
    }) => {
      await api.post('/api/auth/register', {
        first_name: payload.firstName,
        last_name: payload.lastName,
        email: payload.email,
        password: payload.password,
        password_confirm: payload.passwordConfirm,
        security_question: payload.securityQuestion,
        security_answer: payload.securityAnswer,
      })
    },
    [],
  )

  const logout = useCallback(() => {
    setAccessToken(null)
    localStorage.removeItem(mustChangeKey)
    setState({ isLoading: false, accessToken: null, userId: null, mustChangePassword: false })
  }, [])

  const forgotQuestion = useCallback(async (email: string) => {
    const res = await api.post('/api/auth/forgot-password/question', { email })
    return String(res.data?.security_question ?? '')
  }, [])

  const forgotReset = useCallback(async (email: string, securityAnswer: string) => {
    const res = await api.post('/api/auth/forgot-password/reset', { email, security_answer: securityAnswer })
    return String(res.data?.new_password ?? '')
  }, [])

  const changePassword = useCallback(async (oldPassword: string, newPassword: string, newPasswordConfirm: string) => {
    await api.post('/api/auth/change-password', {
      old_password: oldPassword,
      new_password: newPassword,
      new_password_confirm: newPasswordConfirm,
    })

    localStorage.setItem(mustChangeKey, 'false')
    setState((s) => ({ ...s, mustChangePassword: false }))
  }, [])

  const value = useMemo<AuthContextValue>(
    () => ({
      ...state,
      login,
      register,
      logout,
      forgotQuestion,
      forgotReset,
      changePassword,
    }),
    [state, login, register, logout, forgotQuestion, forgotReset, changePassword],
  )

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export function useAuth() {
  const ctx = useContext(AuthContext)
  if (!ctx) throw new Error('useAuth must be used within AuthProvider')
  return ctx
}
