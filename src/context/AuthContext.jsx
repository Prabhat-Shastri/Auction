import React, { createContext, useState, useContext, useEffect } from 'react'
import api from '../services/api'

const AuthContext = createContext()

export function useAuth() {
  return useContext(AuthContext)
}

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {

    const checkAuth = async () => {
      try {
        const username = sessionStorage.getItem('username')
        if (username) {
          setUser({ username })
        }
      } catch (error) {
        console.error('Auth check failed:', error)
      } finally {
        setLoading(false)
      }
    }
    checkAuth()
  }, [])

  const login = async (username, password) => {
    try {
      console.log('Attempting login for:', username)


      const formData = new URLSearchParams()
      formData.append('username', username)
      formData.append('password', password)

      console.log('Sending request to /api/login')
      const response = await api.post('/api/login', formData.toString(), {
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded'
        }
      })

      console.log('Response received:', response)
      console.log('Response data:', response.data)
      console.log('Response data type:', typeof response.data)


      let data = response.data
      if (typeof data === 'string') {
        console.log('Response is string, attempting to parse...')
        try {
          data = JSON.parse(data)
          console.log('Parsed JSON:', data)
        } catch (e) {
          console.error('Failed to parse JSON:', e)

          const text = response.data
          if (text.includes('"success":true') || text.includes("'success':true")) {

            const jsonMatch = text.match(/\{.*\}/)
            if (jsonMatch) {
              data = JSON.parse(jsonMatch[0])
            } else {
              return { success: false, message: 'Invalid response format from server' }
            }
          } else {
            return { success: false, message: 'Invalid response from server: ' + text.substring(0, 100) }
          }
        }
      }

      if (data && data.success) {
        console.log('Login successful!')
        setUser({ username: data.username || username })
        sessionStorage.setItem('username', data.username || username)
        if (data.userId) {
          sessionStorage.setItem('userId', data.userId)
        }
        return { success: true }
      }
      return { success: false, message: data?.message || 'Invalid credentials' }
    } catch (error) {
      console.error('Login error:', error)
      console.error('Error response:', error.response)
      console.error('Error message:', error.message)


      let errorMessage = 'Login failed'
      if (error.response) {
        console.log('Error response status:', error.response.status)
        console.log('Error response data:', error.response.data)

        if (error.response.data) {
          if (typeof error.response.data === 'string') {
            try {
              const errorData = JSON.parse(error.response.data)
              errorMessage = errorData.message || errorMessage
            } catch (e) {
              errorMessage = error.response.data.substring(0, 200) || errorMessage
            }
          } else {
            errorMessage = error.response.data.message || errorMessage
          }
        } else if (error.response.status === 404) {
          errorMessage = 'Login endpoint not found. Make sure Tomcat is running and servlet is compiled.'
        } else if (error.response.status === 500) {
          errorMessage = 'Server error. Check Tomcat logs for details.'
        }
      } else if (error.message) {
        errorMessage = error.message
      }

      return { success: false, message: errorMessage }
    }
  }

  const register = async (username, password) => {
    try {

      const formData = new URLSearchParams()
      formData.append('username', username)
      formData.append('password', password)

      const response = await api.post('/api/register', formData.toString(), {
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded'
        }
      })


      let data = response.data
      if (typeof data === 'string') {
        try {
          data = JSON.parse(data)
        } catch (e) {

          if (response.data.includes('already exists')) {
            return { success: false, message: 'Username already exists' }
          }
          return { success: false, message: 'Registration failed' }
        }
      }

      if (data.success) {
        return { success: true }
      }
      return { success: false, message: data.message || 'Registration failed' }
    } catch (error) {
      console.error('Registration error:', error)
      let errorMessage = 'Registration failed'
      if (error.response?.data) {
        if (typeof error.response.data === 'string') {
          if (error.response.data.includes('already exists')) {
            errorMessage = 'Username already exists'
          } else {
            try {
              const errorData = JSON.parse(error.response.data)
              errorMessage = errorData.message || errorMessage
            } catch (e) {
              errorMessage = error.response.data
            }
          }
        } else {
          errorMessage = error.response.data.message || errorMessage
        }
      }
      return { success: false, message: errorMessage }
    }
  }

  const logout = () => {
    setUser(null)
    sessionStorage.removeItem('username')
    api.post('/api/logout').catch(err => console.error('Logout error:', err))
  }

  const value = {
    user,
    login,
    register,
    logout,
    loading
  }

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

