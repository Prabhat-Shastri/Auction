import React, { useState, useEffect } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import Header from '../components/Header'
import api from '../services/api'
import { useAuth } from '../context/AuthContext'
import './MyAuctions.css'

function MyAuctions() {
  const [myAuctions, setMyAuctions] = useState([])
  const [myBids, setMyBids] = useState([])
  const [loading, setLoading] = useState(true)
  const { user } = useAuth()
  const navigate = useNavigate()

  useEffect(() => {
    fetchMyAuctions()
    fetchMyBids()

    const interval = setInterval(() => {
      api.get('/api/check-winners').catch(err => console.error('Error checking winners:', err))
    }, 60000)
    return () => clearInterval(interval)
  }, [])

  const fetchMyAuctions = async () => {
    try {
      const userId = sessionStorage.getItem('userId')
      if (!userId) return


      const [topsRes, bottomsRes, shoesRes] = await Promise.all([
        api.get('/api/tops').catch(() => ({ data: [] })),
        api.get('/api/bottoms').catch(() => ({ data: [] })),
        api.get('/api/shoes').catch(() => ({ data: [] }))
      ])

      const allItems = [
        ...topsRes.data.map(item => ({ ...item, type: 'top' })),
        ...bottomsRes.data.map(item => ({ ...item, type: 'bottom' })),
        ...shoesRes.data.map(item => ({ ...item, type: 'shoe' }))
      ]

      const myItems = allItems.filter(item => item.sellerId === parseInt(userId))
      setMyAuctions(myItems)
    } catch (error) {
      console.error('Error fetching my auctions:', error)
    } finally {
      setLoading(false)
    }
  }

  const fetchMyBids = async () => {
    try {
      const userId = sessionStorage.getItem('userId')
      if (!userId) return


      const notifications = await api.get('/api/notifications')
      const bidNotifications = notifications.data.filter(n =>
        n.message.includes('won') || n.message.includes('outbid') || n.message.includes('exceeded')
      )
      setMyBids(bidNotifications)
    } catch (error) {
      console.error('Error fetching my bids:', error)
    }
  }

  const checkWinners = async () => {
    try {
      await api.get('/api/check-winners')
      alert('Winner check completed! Check your notifications.')
      fetchMyAuctions()
    } catch (error) {
      console.error('Error checking winners:', error)
      alert('Error checking winners')
    }
  }

  if (loading) {
    return (
      <div className="app">
        <Header />
        <div className="container">
          <p>Loading...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="app">
      <Header />
      <div className="container">
        <div className="page-header">
          <h1>My Auctions</h1>
          <button className="btn btn-secondary" onClick={checkWinners} style={{marginTop: '1rem'}}>
            Check for Winners
          </button>
          <Link to="/" className="btn btn-outline" style={{marginTop: '1rem', marginLeft: '1rem'}}>← Back to Main Page</Link>
        </div>

        <div className="auctions-section">
          <h2>Auctions I Created</h2>
          {myAuctions.length === 0 ? (
            <p>You haven't created any auctions yet.</p>
          ) : (
            <div className="items-grid">
              {myAuctions.map((item) => {
                const isClosed = new Date(item.closeDate + ' ' + item.closeTime) < new Date()
                return (
                  <div key={`${item.type}-${item.id}`} className="item-card">
                    <div className="item-image">
                      {item.imagePath ? (
                        <img src={`/ThriftShop/Images/${item.imagePath}`} alt={item.description} />
                      ) : (
                        <span>{item.type === 'top' ? 'Top' : item.type === 'bottom' ? 'Bottom' : 'Shoe'}</span>
                      )}
                    </div>
                    <div className="item-body">
                      <div className="item-title">
                        {item.description || `${item.type} #${item.id}`}
                      </div>
                      <p><strong>Current Bid:</strong> ${item.currentBidPrice.toFixed(2)}</p>
                      {item.minimumBidPrice !== null && (
                        <p><strong>Reserve Price:</strong> ${item.minimumBidPrice.toFixed(2)}</p>
                      )}
                      <p><strong>Closes:</strong> {item.closeDate} at {item.closeTime}</p>
                      {isClosed && (
                        <div className="status-badge closed">
                          {item.buyerId && item.buyerId > 0 ? 'Sold' : item.buyerId === -1 ? 'No Winner (Reserve Not Met)' : 'No Winner'}
                        </div>
                      )}
                      {!isClosed && (
                        <div className="status-badge active">Active</div>
                      )}
                    </div>
                    <div className="item-footer">
                      <button
                        className="btn btn-secondary"
                        onClick={() => navigate(`/bid-history?itemType=${item.type}&itemId=${item.id}`)}
                      >
                        View Bids
                      </button>
                    </div>
                  </div>
                )
              })}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

export default MyAuctions

