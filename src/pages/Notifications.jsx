import React, { useState, useEffect } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import Header from '../components/Header'
import api from '../services/api'
import './Notifications.css'

function Notifications() {
  const [notifications, setNotifications] = useState([])
  const [loading, setLoading] = useState(true)
  const navigate = useNavigate()

  useEffect(() => {
    fetchNotifications()

    const interval = setInterval(fetchNotifications, 30000)
    return () => clearInterval(interval)
  }, [])

  const fetchNotifications = async () => {
    try {
      const response = await api.get('/api/notifications')
      setNotifications(response.data)
    } catch (error) {
      console.error('Error fetching notifications:', error)
    } finally {
      setLoading(false)
    }
  }

  const markAsRead = async (notificationId) => {
    try {
      await api.post('/api/notifications', new URLSearchParams({
        action: 'markRead',
        notificationId: notificationId.toString()
      }).toString(), {
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded'
        }
      })
      fetchNotifications()
    } catch (error) {
      console.error('Error marking notification as read:', error)
    }
  }

  const viewItem = (notification) => {
    markAsRead(notification.id)
    const itemType = notification.itemType === 'tops' ? 'top' :
                     notification.itemType === 'bottoms' ? 'bottom' : 'shoe'
    navigate(`/bid-history?itemType=${itemType}&itemId=${notification.itemId}`)
  }

  if (loading) {
    return (
      <div className="app">
        <Header />
        <div className="container">
          <p>Loading notifications...</p>
        </div>
      </div>
    )
  }

  const unreadCount = notifications.filter(n => !n.isRead).length

  return (
    <div className="app">
      <Header />
      <div className="container">
        <div className="page-header">
          <h1>Notifications</h1>
          {unreadCount > 0 && (
            <span className="badge">{unreadCount} unread</span>
          )}
          <Link to="/" className="btn btn-outline" style={{marginTop: '1rem'}}>← Back to Main Page</Link>
        </div>

        {notifications.length === 0 ? (
          <div className="no-notifications">
            <p>You have no notifications yet.</p>
          </div>
        ) : (
          <div className="notifications-list">
            {notifications.map((notification) => (
              <div
                key={notification.id}
                className={`notification-card ${!notification.isRead ? 'unread' : ''}`}
                onClick={() => viewItem(notification)}
              >
                <div className="notification-content">
                  <p className="notification-message">{notification.message}</p>
                  <span className="notification-time">
                    {new Date(notification.createdAt).toLocaleString()}
                  </span>
                </div>
                {!notification.isRead && (
                  <button
                    className="btn btn-sm"
                    onClick={(e) => {
                      e.stopPropagation()
                      markAsRead(notification.id)
                    }}
                  >
                    Mark as read
                  </button>
                )}
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}

export default Notifications
