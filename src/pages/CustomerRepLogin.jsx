import React, { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import api from '../services/api'
import './Login.css'

function CustomerRepLogin() {
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const navigate = useNavigate()

  const handleSubmit = async (e) => {
    e.preventDefault()
    setError('')

    try {
      const formData = new URLSearchParams()
      formData.append('username', username)
      formData.append('password', password)

      const response = await api.post('/api/customer-rep/login', formData.toString(), {
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded'
        }
      })

      if (response.data.success) {
        navigate('/customer-rep/dashboard')
      } else {
        setError(response.data.message || 'Login failed')
      }
    } catch (error) {
      console.error('Customer rep login error:', error)
      if (error.response?.data?.message) {
        setError(error.response.data.message)
      } else {
        setError('Login failed. Please check your credentials.')
      }
    }
  }

  return (
    <div className="login-container">
      <div className="login-card">
        <h1>Customer Service Login</h1>
        <h2>ThriftShop Customer Representative</h2>
        {error && <div className="error-message">{error}</div>}
        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label htmlFor="username">Username</label>
            <input
              type="text"
              id="username"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              required
              className="form-control"
            />
          </div>
          <div className="form-group">
            <label htmlFor="password">Password</label>
            <input
              type="password"
              id="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              className="form-control"
            />
          </div>
          <button type="submit" className="btn btn-primary">Login</button>
        </form>
        <p className="register-link" style={{marginTop: '1rem'}}>
          <a href="/login">← Back to User Login</a>
        </p>
      </div>
    </div>
  )
}

export default CustomerRepLogin

