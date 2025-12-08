import React, { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import api from '../services/api'
import './CustomerRepDashboard.css'

function CustomerRepDashboard() {
  const [unansweredFaqs, setUnansweredFaqs] = useState([])
  const [allFaqs, setAllFaqs] = useState([])
  const [bids, setBids] = useState([])
  const [auctions, setAuctions] = useState([])
  const [users, setUsers] = useState([])
  const [activeTab, setActiveTab] = useState('unanswered')
  const [loading, setLoading] = useState(false)
  const [answerText, setAnswerText] = useState({})
  const [passwordText, setPasswordText] = useState({})
  const [showPasswords, setShowPasswords] = useState({})
  const [message, setMessage] = useState('')
  const navigate = useNavigate()

  useEffect(() => {

    api.get('/api/faqs?unansweredOnly=true')
      .then(() => {

        loadFaqs()
        loadUsers()
      })
      .catch((err) => {
        if (err.response?.status === 401 || err.response?.status === 403) {
          navigate('/customer-rep/login')
        }
      })
  }, [navigate])

  const loadFaqs = async () => {
    setLoading(true)
    try {

      const unansweredResponse = await api.get('/api/faqs?unansweredOnly=true')
      let unansweredData = unansweredResponse.data
      if (typeof unansweredData === 'string') {
        try {
          unansweredData = JSON.parse(unansweredData)
        } catch (e) {
          console.error('Failed to parse unanswered FAQs JSON:', e)
        }
      }
      setUnansweredFaqs(Array.isArray(unansweredData) ? unansweredData : [])


      const allResponse = await api.get('/api/faqs')
      let allData = allResponse.data
      if (typeof allData === 'string') {
        try {
          allData = JSON.parse(allData)
        } catch (e) {
          console.error('Failed to parse all FAQs JSON:', e)
        }
      }
      setAllFaqs(Array.isArray(allData) ? allData : [])
    } catch (error) {
      console.error('Error loading FAQs:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleAnswer = async (faqId) => {
    const answer = answerText[faqId]
    if (!answer || !answer.trim()) {
      setMessage('Please enter an answer')
      return
    }

    setLoading(true)
    setMessage('')

    try {
      const formData = new URLSearchParams()
      formData.append('faqId', faqId)
      formData.append('answer', answer)

      const response = await api.post('/api/faqs', formData.toString(), {
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded'
        }
      })

      if (response.data.success) {
        setMessage('Answer posted successfully!')
        setAnswerText({ ...answerText, [faqId]: '' })
        loadFaqs()
      } else {
        setMessage(response.data.message || 'Failed to post answer')
      }
    } catch (error) {
      console.error('Error posting answer:', error)
      setMessage('Failed to post answer')
    } finally {
      setLoading(false)
    }
  }

  const loadBidsAndAuctions = async () => {
    setLoading(true)
    try {
      const response = await api.get('/api/customer-rep/manage')
      let data = response.data
      if (typeof data === 'string') {
        try {
          data = JSON.parse(data)
        } catch (e) {
          console.error('Failed to parse data JSON:', e)
          return
        }
      }
      setBids(Array.isArray(data.bids) ? data.bids : [])
      setAuctions(Array.isArray(data.auctions) ? data.auctions : [])
    } catch (error) {
      console.error('Error loading bids and auctions:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleRemoveBid = async (bidId) => {
    if (!window.confirm('Are you sure you want to remove this bid?')) {
      return
    }

    setLoading(true)
    setMessage('')

    try {
      const formData = new URLSearchParams()
      formData.append('action', 'removeBid')
      formData.append('bidId', bidId)

      const response = await api.post('/api/customer-rep/manage', formData.toString(), {
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded'
        }
      })

      if (response.data.success) {
        setMessage('Bid removed successfully!')
        loadBidsAndAuctions()
      } else {
        setMessage(response.data.message || 'Failed to remove bid')
      }
    } catch (error) {
      console.error('Error removing bid:', error)
      setMessage('Failed to remove bid')
    } finally {
      setLoading(false)
    }
  }

  const handleRemoveAuction = async (auctionId, itemType) => {
    if (!window.confirm('Are you sure you want to remove this auction?')) {
      return
    }

    setLoading(true)
    setMessage('')

    try {
      const formData = new URLSearchParams()
      formData.append('action', 'removeAuction')
      formData.append('auctionId', auctionId)
      formData.append('itemType', itemType)

      const response = await api.post('/api/customer-rep/manage', formData.toString(), {
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded'
        }
      })

      if (response.data.success) {
        setMessage('Auction removed successfully!')
        loadBidsAndAuctions()
      } else {
        setMessage(response.data.message || 'Failed to remove auction')
      }
    } catch (error) {
      console.error('Error removing auction:', error)
      setMessage('Failed to remove auction')
    } finally {
      setLoading(false)
    }
  }

  const loadUsers = async () => {
    setLoading(true)
    try {
      const response = await api.get('/api/customer-rep/users')
      let data = response.data
      if (typeof data === 'string') {
        try {
          data = JSON.parse(data)
        } catch (e) {
          console.error('Failed to parse users JSON:', e)
          return
        }
      }
      setUsers(Array.isArray(data) ? data : [])
    } catch (error) {
      console.error('Error loading users:', error)
      setMessage('Failed to load users')
    } finally {
      setLoading(false)
    }
  }

  const handleUpdatePassword = async (userId) => {
    setMessage('')
    const newPassword = passwordText[userId]
    if (!newPassword || !newPassword.trim()) {
      setMessage('Please enter a new password')
      return
    }

    setLoading(true)
    try {
      const response = await api.post('/api/customer-rep/users', {
        userId: userId,
        newPassword: newPassword,
        action: 'update'
      }, {
        headers: {
          'Content-Type': 'application/json'
        }
      })

      if (response.data.success) {
        setMessage('Password updated successfully!')
        setPasswordText(prev => {
          const newState = { ...prev }
          delete newState[userId]
          return newState
        })
        loadUsers()
      } else {
        setMessage(response.data.message || 'Failed to update password')
      }
    } catch (error) {
      console.error('Error updating password:', error)
      setMessage('Failed to update password')
    } finally {
      setLoading(false)
    }
  }

  const handleDeleteUser = async (userId) => {
    if (!window.confirm('Are you sure you want to delete this user? This action cannot be undone.')) {
      return
    }

    setMessage('')
    setLoading(true)
    try {
      const response = await api.post('/api/customer-rep/users', {
        userId: userId,
        action: 'delete'
      }, {
        headers: {
          'Content-Type': 'application/json'
        }
      })

      if (response.data.success) {
        setMessage('User deleted successfully!')
        loadUsers()
      } else {
        setMessage(response.data.message || 'Failed to delete user')
      }
    } catch (error) {
      console.error('Error deleting user:', error)
      setMessage('Failed to delete user')
    } finally {
      setLoading(false)
    }
  }

  const handleLogout = async () => {
    try {
      await api.post('/api/logout')
    } catch (error) {
      console.error('Logout error:', error)
    }
    navigate('/customer-rep/login')
  }

  return (
    <div className="customer-rep-dashboard">
      <div className="dashboard-header">
        <h1>Customer Service Dashboard</h1>
        <button className="btn btn-secondary" onClick={handleLogout}>Logout</button>
      </div>

      <div className="dashboard-tabs">
        <button
          className={activeTab === 'unanswered' ? 'tab-active' : 'tab'}
          onClick={() => setActiveTab('unanswered')}
        >
          Unanswered Questions ({unansweredFaqs.length})
        </button>
        <button
          className={activeTab === 'all' ? 'tab-active' : 'tab'}
          onClick={() => setActiveTab('all')}
        >
          All FAQs
        </button>
        <button
          className={activeTab === 'bids' ? 'tab-active' : 'tab'}
          onClick={() => {
            setActiveTab('bids')
            loadBidsAndAuctions()
          }}
        >
          Manage Bids ({bids.length})
        </button>
        <button
          className={activeTab === 'auctions' ? 'tab-active' : 'tab'}
          onClick={() => {
            setActiveTab('auctions')
            loadBidsAndAuctions()
          }}
        >
          Manage Auctions ({auctions.length})
        </button>
        <button
          className={activeTab === 'users' ? 'tab-active' : 'tab'}
          onClick={() => {
            setActiveTab('users')
            loadUsers()
          }}
        >
          Manage Users ({users.length})
        </button>
      </div>

      <div className="dashboard-content">
        {message && <div className={`message ${message.toLowerCase().includes('success') || message.toLowerCase().includes('removed') || message.toLowerCase().includes('posted') ? 'success' : 'error'}`}>{message}</div>}

        {activeTab === 'unanswered' && (
          <div className="faqs-section">
            <h2>Unanswered Questions</h2>
            {loading && <p>Loading...</p>}
            {!loading && unansweredFaqs.length === 0 && (
                      <p className="no-faqs">No unanswered questions. Great job!</p>
            )}
            {!loading && unansweredFaqs.map((faq) => (
              <div key={faq.faqId} className="faq-item unanswered">
                <div className="faq-question">
                  <strong>Q:</strong> {faq.question}
                  <span className="faq-meta">
                    Asked by {faq.askerUsername} on {new Date(faq.createdAt).toLocaleDateString()}
                  </span>
                </div>
                <div className="answer-section">
                  <textarea
                    value={answerText[faq.faqId] || ''}
                    onChange={(e) => setAnswerText({ ...answerText, [faq.faqId]: e.target.value })}
                    placeholder="Type your answer here..."
                    rows="4"
                    className="answer-input"
                  />
                  <button
                    onClick={() => handleAnswer(faq.faqId)}
                    className="btn btn-primary"
                    disabled={loading}
                  >
                    Post Answer
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}

        {activeTab === 'all' && (
          <div className="faqs-section">
            <h2>All FAQs</h2>
            {loading && <p>Loading...</p>}
            {!loading && allFaqs.map((faq) => (
              <div key={faq.faqId} className={`faq-item ${faq.isAnswered ? 'answered' : 'unanswered'}`}>
                <div className="faq-question">
                  <strong>Q:</strong> {faq.question}
                  <span className="faq-meta">
                    Asked by {faq.askerUsername} on {new Date(faq.createdAt).toLocaleDateString()}
                  </span>
                </div>
                {faq.isAnswered && faq.answer && (
                  <div className="faq-answer">
                    <strong>A:</strong> {faq.answer}
                    <span className="faq-meta">
                      Answered by {faq.answererUsername} on {new Date(faq.answeredAt).toLocaleDateString()}
                    </span>
                  </div>
                )}
                {!faq.isAnswered && (
                          <div className="faq-pending">Not answered yet</div>
                )}
              </div>
            ))}
          </div>
        )}

        {activeTab === 'bids' && (
          <div className="faqs-section">
            <h2>Manage Bids</h2>
            {loading && <p>Loading...</p>}
            {!loading && bids.length === 0 && (
              <p className="no-faqs">No active bids found.</p>
            )}
            {!loading && bids.map((bid) => (
              <div key={bid.bidId} className="faq-item">
                <div className="faq-question">
                  <strong>Bid ID:</strong> {bid.bidId} |
                  <strong> Item:</strong> {bid.itemType} #{bid.itemId} |
                  <strong> Amount:</strong> ${bid.bidAmount} |
                  <strong> Buyer:</strong> {bid.buyerUsername}
                </div>
                <button
                  onClick={() => handleRemoveBid(bid.bidId)}
                  className="btn btn-danger"
                  disabled={loading}
                  style={{ marginTop: '0.5rem' }}
                >
                  Remove Bid
                </button>
              </div>
            ))}
          </div>
        )}

        {activeTab === 'auctions' && (
          <div className="faqs-section">
            <h2>Manage Auctions</h2>
            {loading && <p>Loading...</p>}
            {!loading && auctions.length === 0 && (
              <p className="no-faqs">No active auctions found.</p>
            )}
            {!loading && auctions.map((auction) => (
              <div key={`${auction.itemType}-${auction.itemId}`} className="faq-item">
                <div className="faq-question">
                  <strong>Item ID:</strong> {auction.itemId} |
                  <strong> Type:</strong> {auction.itemType} |
                  <strong> Description:</strong> {auction.description} |
                  <strong> Current Bid:</strong> ${auction.currentBid} |
                  <strong> Seller:</strong> {auction.sellerUsername}
                </div>
                <button
                  onClick={() => handleRemoveAuction(auction.itemId, auction.itemType)}
                  className="btn btn-danger"
                  disabled={loading}
                  style={{ marginTop: '0.5rem' }}
                >
                  Remove Auction
                </button>
              </div>
            ))}
          </div>
        )}

        {activeTab === 'users' && (
          <div className="faqs-section">
            <h2>Manage Regular Users</h2>
            {loading && <p>Loading...</p>}
            {!loading && users.length === 0 && (
              <p className="no-faqs">No regular users found.</p>
            )}
            {!loading && users.map((user) => (
              <div key={user.userId} className="faq-item">
                <div className="faq-question">
                  <strong>User ID:</strong> {user.userId} |
                  <strong> Username:</strong> {user.username} |
                  <strong> Role:</strong> Regular User
                </div>
                <div className="answer-section" style={{ marginTop: '1rem' }}>
                  <div style={{ display: 'flex', gap: '1rem', alignItems: 'center', marginBottom: '0.5rem', flexWrap: 'wrap' }}>
                    <input
                      type={showPasswords[user.userId] ? "text" : "password"}
                      value={passwordText[user.userId] || ''}
                      onChange={(e) => setPasswordText({ ...passwordText, [user.userId]: e.target.value })}
                      placeholder="Enter new password"
                      className="answer-input"
                      style={{ flex: 1, maxWidth: '300px' }}
                    />
                    <label style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', cursor: 'pointer' }}>
                      <input
                        type="checkbox"
                        checked={showPasswords[user.userId] || false}
                        onChange={(e) => setShowPasswords({ ...showPasswords, [user.userId]: e.target.checked })}
                        style={{ cursor: 'pointer' }}
                      />
                      <span>Show Password</span>
                    </label>
                    <button
                      onClick={() => handleUpdatePassword(user.userId)}
                      className="btn btn-primary"
                      disabled={loading || !passwordText[user.userId]?.trim()}
                    >
                      Update Password
                    </button>
                    <button
                      onClick={() => handleDeleteUser(user.userId)}
                      className="btn btn-danger"
                      disabled={loading}
                    >
                      Delete User
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}

export default CustomerRepDashboard

