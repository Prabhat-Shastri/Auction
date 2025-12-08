import React, { useState, useEffect } from 'react'
import { Link, useNavigate, useSearchParams } from 'react-router-dom'
import Header from '../components/Header'
import api from '../services/api'
import { useAuth } from '../context/AuthContext'
import './Tops.css'

function UserAuctions() {
  const [items, setItems] = useState([])
  const [loading, setLoading] = useState(true)
  const [searchParams] = useSearchParams()
  const role = searchParams.get('role') || 'buyer'
  const { user } = useAuth()
  const navigate = useNavigate()

  useEffect(() => {
    fetchUserAuctions()
  }, [role])

  const fetchUserAuctions = async () => {
    try {
      setLoading(true)
      const response = await api.get(`/api/user-auctions?role=${role}`)
      setItems(response.data)
    } catch (error) {
      console.error('Error fetching user auctions:', error)
      alert('Failed to fetch auctions')
    } finally {
      setLoading(false)
    }
  }

  const viewBidHistory = (item) => {
    navigate(`/bid-history?itemType=${item.type}&itemId=${item.id}`)
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
          <h1>{role === 'buyer' ? 'My Bids' : 'My Auctions'}</h1>
          <div style={{display: 'flex', gap: '1rem', marginTop: '1rem'}}>
            <Link
              to="/user-auctions?role=buyer"
              className={`btn ${role === 'buyer' ? 'btn-primary' : 'btn-outline'}`}
            >
              My Bids
            </Link>
            <Link
              to="/user-auctions?role=seller"
              className={`btn ${role === 'seller' ? 'btn-primary' : 'btn-outline'}`}
            >
              My Auctions
            </Link>
            <Link to="/" className="btn btn-outline">← Back to Main Page</Link>
          </div>
        </div>

        {items.length === 0 ? (
          <div className="no-items">
            <p>{role === 'buyer' ? 'You haven\'t placed any bids yet.' : 'You haven\'t created any auctions yet.'}</p>
          </div>
        ) : (
          <div className="items-grid">
            {items.map((item) => {
              const isClosed = new Date(item.closeDate + ' ' + item.closeTime) < new Date()
              const isSeller = user && item.sellerId === parseInt(sessionStorage.getItem('userId'))
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
                    <div className="item-meta">
                      <span>Type: {item.type}</span> |
                      <span> Seller: {item.sellerUsername}</span> |
                      <span> {item.gender}</span> |
                      <span> Size: {item.size}</span> |
                      <span> Color: {item.color}</span>
                    </div>

                    <p><strong>Description:</strong> {item.description}</p>
                    <p><strong>Condition:</strong> {item.condition}</p>

                    {isSeller && item.minimumBidPrice !== null && (
                      <div className="reserve-badge">
                        Reserve: ${item.minimumBidPrice.toFixed(2)} (Hidden)
                      </div>
                    )}

                    <div className="item-price">
                      Current Bid: ${item.currentBidPrice.toFixed(2)}
                    </div>
                    <p className="close-time">
                      <strong>⏰ Closes:</strong> {item.closeDate} at {item.closeTime}
                    </p>
                    {isClosed && (
                      <div className="status-badge" style={{
                        background: item.buyerId && item.buyerId > 0 ? '#d4edda' : '#f8d7da',
                        color: item.buyerId && item.buyerId > 0 ? '#155724' : '#721c24',
                        padding: '0.5rem 1rem',
                        borderRadius: '8px',
                        marginTop: '1rem',
                        display: 'inline-block'
                      }}>
                        {item.buyerId && item.buyerId > 0 ? 'Sold' : 'Closed'}
                      </div>
                    )}
                  </div>

                  <div className="item-footer">
                    <button
                      className="btn btn-secondary"
                      onClick={() => viewBidHistory(item)}
                    >
                      View Bid History
                    </button>
                  </div>
                </div>
              )
            })}
          </div>
        )}
      </div>
    </div>
  )
}

export default UserAuctions

