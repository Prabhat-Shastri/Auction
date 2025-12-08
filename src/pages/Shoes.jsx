import React, { useState, useEffect } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import Header from '../components/Header'
import api from '../services/api'
import { useAuth } from '../context/AuthContext'
import './Tops.css'

function Shoes() {
  const [items, setItems] = useState([])
  const [loading, setLoading] = useState(true)
  const [selectedItem, setSelectedItem] = useState(null)
  const [bidAmount, setBidAmount] = useState('')
  const [autoIncrement, setAutoIncrement] = useState('')
  const [maxBid, setMaxBid] = useState('')
  const [enableAutoBid, setEnableAutoBid] = useState(false)
  const { user } = useAuth()
  const navigate = useNavigate()

  useEffect(() => {
    fetchItems()

    const interval = setInterval(() => {
      api.get('/api/check-winners').catch(err => console.error('Error checking winners:', err))
      fetchItems()
    }, 30000)
    return () => clearInterval(interval)
  }, [])

  const fetchItems = async () => {
    try {
      const response = await api.get('/api/shoes')
      setItems(response.data)
    } catch (error) {
      console.error('Error fetching shoes:', error)
    } finally {
      setLoading(false)
    }
  }

  const handlePlaceBid = async (itemId) => {
    if (!bidAmount || parseFloat(bidAmount) <= 0) {
      alert('Please enter a valid bid amount')
      return
    }

    try {
      const formData = new URLSearchParams()
      formData.append('itemType', 'shoe')
      formData.append('itemId', itemId)
      formData.append('newBid', bidAmount)
      formData.append('autoIncrement', autoIncrement)
      formData.append('maxBid', maxBid)

      const response = await api.post('/api/bid', formData.toString(), {
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded'
        }
      })

      if (response.data.success) {
        alert('Bid placed successfully!')
        setSelectedItem(null)
        setBidAmount('')
        fetchItems()
      } else {
        alert(response.data.message || 'Failed to place bid')
      }
    } catch (error) {
      console.error('Error placing bid:', error)
      alert(error.response?.data?.message || 'Failed to place bid')
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
          <h1>Shoes</h1>
          <p>Browse and bid on premium shoes</p>
          <Link to="/" className="btn btn-outline" style={{marginTop: '1rem'}}>← Back to Main Page</Link>
        </div>

        {items.length === 0 ? (
          <div className="no-items">
            <p>No shoes available at the moment.</p>
          </div>
        ) : (
          <div className="items-grid">
            {items.map((item) => {
              const isSeller = user && item.sellerId === parseInt(sessionStorage.getItem('userId'))


              const isAuctionClosed = () => {
                try {
                  const closeDateTime = new Date(`${item.closeDate}T${item.closeTime}`)
                  return new Date() > closeDateTime
                } catch (e) {
                  return false
                }
              }
              const auctionClosed = isAuctionClosed()

              return (
                <div key={item.id} className={`item-card ${auctionClosed ? 'auction-closed' : ''}`}>
                  {auctionClosed && <div className="closed-badge">AUCTION CLOSED</div>}
                  <div className="item-image">
                    {(() => {

                      let images = item.images;


                      if (typeof images === 'string') {
                        try {
                          images = JSON.parse(images);
                        } catch (e) {
                          images = [];
                        }
                      }


                      if (!images || !Array.isArray(images) || images.length === 0) {
                        images = item.imagePath ? [item.imagePath] : [];
                      }

                      if (images.length === 0) {
                        return <span>No Image</span>;
                      }

                      if (images.length === 1) {
                        return <img src={`/ThriftShop/Images/${images[0]}`} alt={item.description} />;
                      }


                      return (
                        <div className="image-gallery">
                          <img src={`/ThriftShop/Images/${images[0]}`} alt={item.description} className="main-image" />
                          <div className="image-thumbnails">
                            {images.slice(1).map((img, idx) => (
                              <img
                                key={idx}
                                src={`/ThriftShop/Images/${img}`}
                                alt={`${item.description} ${idx + 2}`}
                                className="thumbnail"
                                onError={(e) => {
                                  console.error('Failed to load image:', img);
                                  e.target.style.display = 'none';
                                }}
                              />
                            ))}
                          </div>
                        </div>
                      );
                    })()}
                  </div>
                  <div className="item-body">
                    <div className="item-title">
                      {item.description || `Shoe #${item.id}`}
                    </div>
                    <div className="item-meta">
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
                  </div>

                  <div className="item-footer">
                    <button
                      className="btn btn-primary"
                      onClick={() => setSelectedItem(item)}
                      style={{marginRight: '0.5rem'}}
                      disabled={auctionClosed}
                    >
                      {auctionClosed ? 'Bidding Closed' : 'Place Bid'}
                    </button>
                    <button
                      className="btn btn-secondary"
                      onClick={() => navigate(`/bid-history?itemType=shoe&itemId=${item.id}`)}
                    >
                      Bid History
                    </button>
                  </div>
                </div>
              )
            })}
          </div>
        )}

        {selectedItem && (
          <div className="bid-modal-overlay" onClick={() => setSelectedItem(null)}>
            <div className="bid-modal" onClick={(e) => e.stopPropagation()}>
              <span className="modal-close" onClick={() => setSelectedItem(null)}>&times;</span>
              <h2>Place Bid on {selectedItem.description || `Shoe #${selectedItem.id}`}</h2>
              <p>Current Bid: ${selectedItem.currentBidPrice.toFixed(2)}</p>
              <div className="form-group">
                <label>Bid Amount (USD)</label>
                <input
                  type="number"
                  value={bidAmount}
                  onChange={(e) => setBidAmount(e.target.value)}
                  min={selectedItem.currentBidPrice}
                  step="0.01"
                  className="form-control"
                  required
                />
              </div>
              <div className="form-group">
                <label>
                  <input
                    type="checkbox"
                    checked={enableAutoBid}
                    onChange={(e) => {
                      setEnableAutoBid(e.target.checked)
                      if (!e.target.checked) {
                        setAutoIncrement('')
                        setMaxBid('')
                      }
                    }}
                    style={{marginRight: '0.5rem'}}
                  />
                  Enable Automatic Bidding
                </label>
              </div>
              {enableAutoBid && (
                <>
                  <div className="form-group">
                    <label>Bid Increment (USD) - Secret</label>
                    <input
                      type="number"
                      value={autoIncrement}
                      onChange={(e) => setAutoIncrement(e.target.value)}
                      className="form-control"
                      step="0.01"
                      min="0.01"
                      placeholder="e.g., 5.00"
                    />
                    <small style={{color: 'var(--text-secondary)'}}>Amount to increase bid automatically</small>
                  </div>
                  <div className="form-group">
                    <label>Maximum Bid (USD) - Secret Upper Limit</label>
                    <input
                      type="number"
                      value={maxBid}
                      onChange={(e) => setMaxBid(e.target.value)}
                      step="0.01"
                      min={selectedItem.currentBidPrice}
                      className="form-control"
                      placeholder="Your secret max bid"
                    />
                    <small style={{color: 'var(--text-secondary)'}}>Your maximum bid amount (hidden from others)</small>
                  </div>
                </>
              )}
              <div style={{display: 'flex', gap: '1rem'}}>
                <button
                  className="btn btn-primary"
                  onClick={() => handlePlaceBid(selectedItem.id)}
                >
                  Place Bid
                </button>
                <button
                  className="btn btn-secondary"
                  onClick={() => {
                    setSelectedItem(null)
                    setBidAmount('')
                    setAutoIncrement('')
                    setMaxBid('')
                    setEnableAutoBid(false)
                  }}
                >
                  Cancel
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}

export default Shoes
