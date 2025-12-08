import React, { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import api from '../services/api'
import './AdminDashboard.css'

function AdminDashboard() {
  const [activeTab, setActiveTab] = useState('createRep')
  const [repUsername, setRepUsername] = useState('')
  const [repPassword, setRepPassword] = useState('')
  const [repMessage, setRepMessage] = useState('')
  const [salesReport, setSalesReport] = useState(null)
  const [loading, setLoading] = useState(false)
  const [startDate, setStartDate] = useState('')
  const [endDate, setEndDate] = useState('')
  const navigate = useNavigate()

  useEffect(() => {

    api.get('/api/admin/sales-report')
      .then(() => {

      })
      .catch((err) => {
        if (err.response?.status === 401 || err.response?.status === 403) {
          navigate('/admin/login')
        }
      })
  }, [navigate])

  const handleCreateRep = async (e) => {
    e.preventDefault()
    setRepMessage('')
    setLoading(true)

    try {
      const formData = new URLSearchParams()
      formData.append('username', repUsername)
      formData.append('password', repPassword)

      const response = await api.post('/api/admin/create-customer-rep', formData.toString(), {
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded'
        }
      })

      if (response.data.success) {
        setRepMessage('Customer representative account created successfully!')
        setRepUsername('')
        setRepPassword('')
      } else {
        setRepMessage(response.data.message || 'Failed to create account')
      }
    } catch (error) {
      console.error('Error creating customer rep:', error)
      if (error.response?.data?.message) {
        setRepMessage(error.response.data.message)
      } else {
        setRepMessage('Failed to create customer representative account')
      }
    } finally {
      setLoading(false)
    }
  }

  const loadSalesReport = async () => {
    setLoading(true)
    try {

      const params = new URLSearchParams()
      if (startDate) {
        params.append('startDate', startDate)
      }
      if (endDate) {
        params.append('endDate', endDate)
      }

      const url = '/api/admin/sales-report' + (params.toString() ? '?' + params.toString() : '')
      const response = await api.get(url)
      console.log('Sales Report Response:', response.data)
      console.log('Sales Report Response Type:', typeof response.data)


      let reportData = response.data
      if (typeof reportData === 'string') {
        try {
          reportData = JSON.parse(reportData)
          console.log('Parsed sales report data:', reportData)
        } catch (e) {
          console.error('Failed to parse sales report JSON:', e)
          console.error('JSON string length:', reportData.length)
          console.error('JSON around error position (353):', reportData.substring(Math.max(0, 350), Math.min(reportData.length, 360)))
          console.error('Full JSON string:', reportData)
          alert('Failed to parse sales report data. Check console for details.')
          return
        }
      }

      console.log('Setting sales report data:', reportData)
      console.log('earningsPerItemType:', reportData.earningsPerItemType)
      console.log('Type of earningsPerItemType:', typeof reportData.earningsPerItemType)
      console.log('Is array?', Array.isArray(reportData.earningsPerItemType))

      setSalesReport(reportData)
      setActiveTab('reports')
    } catch (error) {
      console.error('Error loading sales report:', error)
      alert('Failed to load sales report')
    } finally {
      setLoading(false)
    }
  }

  const handleLogout = async () => {
    try {
      await api.post('/api/logout')
      navigate('/admin/login')
    } catch (error) {
      console.error('Logout error:', error)

      navigate('/admin/login')
    }
  }

  return (
    <div className="admin-dashboard">
      <div className="admin-header">
        <h1>Admin Dashboard</h1>
        <button className="btn btn-secondary" onClick={handleLogout}>Logout</button>
      </div>

      <div className="admin-tabs">
        <button
          className={activeTab === 'createRep' ? 'tab-active' : 'tab'}
          onClick={() => setActiveTab('createRep')}
        >
          Create Customer Rep
        </button>
        <button
          className={activeTab === 'reports' ? 'tab-active' : 'tab'}
          onClick={loadSalesReport}
        >
          Sales Reports
        </button>
      </div>

      <div className="admin-content">
        {activeTab === 'createRep' && (
          <div className="admin-section">
            <h2>Create Customer Representative Account</h2>
            <form onSubmit={handleCreateRep} className="admin-form">
              <div className="form-group">
                <label>Username</label>
                <input
                  type="text"
                  value={repUsername}
                  onChange={(e) => setRepUsername(e.target.value)}
                  required
                  className="form-control"
                />
              </div>
              <div className="form-group">
                <label>Password</label>
                <input
                  type="password"
                  value={repPassword}
                  onChange={(e) => setRepPassword(e.target.value)}
                  required
                  className="form-control"
                />
              </div>
              <button type="submit" className="btn btn-primary" disabled={loading}>
                {loading ? 'Creating...' : 'Create Account'}
              </button>
              {repMessage && (
                <div className={repMessage.toLowerCase().includes('success') ? 'success-message' : 'error-message'}>
                  {repMessage}
                </div>
              )}
            </form>
          </div>
        )}

        {activeTab === 'reports' && (
          <div className="admin-section">
            <h2>Sales Reports</h2>

            <div className="date-range-filter" style={{ marginBottom: '20px', padding: '15px', backgroundColor: '#f5f5f5', borderRadius: '8px' }}>
              <h3 style={{ marginTop: 0, marginBottom: '15px' }}>📅 Filter by Date Range</h3>
              <div style={{ display: 'flex', gap: '15px', alignItems: 'center', flexWrap: 'wrap' }}>
                <div>
                  <label style={{ display: 'block', marginBottom: '5px', fontWeight: 'bold' }}>Start Date:</label>
                  <input
                    type="date"
                    value={startDate}
                    onChange={(e) => setStartDate(e.target.value)}
                    style={{ padding: '8px', borderRadius: '4px', border: '1px solid #ddd', fontSize: '14px' }}
                  />
                </div>
                <div>
                  <label style={{ display: 'block', marginBottom: '5px', fontWeight: 'bold' }}>End Date:</label>
                  <input
                    type="date"
                    value={endDate}
                    onChange={(e) => setEndDate(e.target.value)}
                    style={{ padding: '8px', borderRadius: '4px', border: '1px solid #ddd', fontSize: '14px' }}
                  />
                </div>
                <div style={{ display: 'flex', gap: '10px', alignItems: 'flex-end' }}>
                  <button
                    type="button"
                    onClick={loadSalesReport}
                    className="btn btn-primary"
                    style={{ padding: '8px 20px', height: 'fit-content' }}
                  >
                    Apply Filter
                  </button>
                  <button
                    type="button"
                    onClick={() => {
                      setStartDate('')
                      setEndDate('')
                      loadSalesReport()
                    }}
                    className="btn btn-secondary"
                    style={{ padding: '8px 20px', height: 'fit-content' }}
                  >
                    Clear
                  </button>
                </div>
              </div>
              {(startDate || endDate) && (
                <p style={{ marginTop: '10px', fontSize: '12px', color: '#666' }}>
                  Showing reports from {startDate || 'beginning'} to {endDate || 'today'}
                </p>
              )}
            </div>

            {loading && <p>Loading...</p>}
            {!loading && !salesReport && (
              <p style={{ padding: '20px', textAlign: 'center', color: '#666' }}>
                Click "Apply Filter" to generate sales report
              </p>
            )}
            {salesReport && (
              <div className="sales-report">
                <div className="report-section">
                  <h3>Total Earnings</h3>
                  <p className="big-number">${(salesReport.totalEarnings || 0).toFixed(2)}</p>
                </div>

                <div className="report-section">
                  <h3>Earnings per Item Type</h3>
                  <table className="report-table">
                    <thead>
                      <tr>
                        <th>Item Type</th>
                        <th>Total Earnings</th>
                      </tr>
                    </thead>
                    <tbody>
                      {(salesReport.earningsPerItemType || []).map((item, idx) => (
                        <tr key={idx}>
                          <td>{item.itemType}</td>
                          <td>${(item.totalEarnings || 0).toFixed(2)}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>

                <div className="report-section">
                  <h3>👥 Best Buyers (Top 10 - by Final Winning Bid)</h3>
                  <table className="report-table">
                    <thead>
                      <tr>
                        <th>User ID</th>
                        <th>Username</th>
                        <th>Highest Final Bid</th>
                      </tr>
                    </thead>
                    <tbody>
                      {(salesReport.bestBuyers || []).map((buyer, idx) => (
                        <tr key={idx}>
                          <td>{buyer.userId}</td>
                          <td>{buyer.username}</td>
                          <td>${(buyer.totalSpent || 0).toFixed(2)}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>

                <div className="report-section">
                  <h3>🏆 Best-Selling Items (Top 10)</h3>
                  <table className="report-table">
                    <thead>
                      <tr>
                        <th>Item ID</th>
                        <th>Description</th>
                        <th>Type</th>
                        <th>Final Price</th>
                      </tr>
                    </thead>
                    <tbody>
                      {(salesReport.bestSellingItems || []).map((item, idx) => (
                        <tr key={idx}>
                          <td>{item.itemId}</td>
                          <td>{item.description}</td>
                          <td>{item.itemType}</td>
                          <td>${(item.price || 0).toFixed(2)}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>

                <div className="report-section">
                  <h3>💵 Earnings per Seller</h3>
                  <table className="report-table">
                    <thead>
                      <tr>
                        <th>User ID</th>
                        <th>Username</th>
                        <th>Total Earnings</th>
                      </tr>
                    </thead>
                    <tbody>
                      {(salesReport.earningsPerEndUser || []).map((user, idx) => (
                        <tr key={idx}>
                          <td>{user.userId}</td>
                          <td>{user.username}</td>
                          <td>${(user.totalSpent || 0).toFixed(2)}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  )
}

export default AdminDashboard

