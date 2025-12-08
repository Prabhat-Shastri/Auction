import React, { useState, useEffect } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import Header from '../components/Header'
import api from '../services/api'
import { useAuth } from '../context/AuthContext'
import './Tops.css'

function Search() {
  const [items, setItems] = useState([])
  const [loading, setLoading] = useState(false)
  const [searchParams, setSearchParams] = useState({
    itemType: 'any',
    gender: '',
    size: '',
    color: '',
    description: '',
    condition: '',
    minPrice: '',
    maxPrice: '',
    seller: '',
    sortBy: 'price',
    sortOrder: 'asc'
  })
  const [selectedItem, setSelectedItem] = useState(null)
  const [bidAmount, setBidAmount] = useState('')
  const [autoIncrement, setAutoIncrement] = useState('')
  const [maxBid, setMaxBid] = useState('')
  const [enableAutoBid, setEnableAutoBid] = useState(false)
  const [showAlertForm, setShowAlertForm] = useState(false)
  const [alertPreferences, setAlertPreferences] = useState([])
  const [alertForm, setAlertForm] = useState({
    itemType: 'top',
    gender: '',
    size: '',
    color: ''
  })
  const { user } = useAuth()
  const navigate = useNavigate()

  useEffect(() => {

    const interval = setInterval(() => {
      api.get('/api/check-winners').catch(err => console.error('Error checking winners:', err))
    }, 30000)
    return () => clearInterval(interval)
  }, [])

  useEffect(() => {

    if (user) {
      loadAlertPreferences()
    }
  }, [user])

  const loadAlertPreferences = async () => {
    try {
      const response = await api.get('/api/alert-preferences')
      setAlertPreferences(Array.isArray(response.data) ? response.data : [])
    } catch (error) {
      console.error('Error loading alert preferences:', error)
    }
  }

  const handleCreateAlert = async (e) => {
    e.preventDefault()
    if (!alertForm.itemType) {
      alert('Please select an item type')
      return
    }

    try {
      const response = await api.post('/api/alert-preferences', alertForm, {
        headers: {
          'Content-Type': 'application/json'
        }
      })

      if (response.data.success) {
        alert('Alert preference created! You will be notified when matching items are listed.')
        setShowAlertForm(false)
        setAlertForm({ itemType: 'top', gender: '', size: '', color: '' })
        loadAlertPreferences()
      } else {
        alert(response.data.message || 'Failed to create alert')
      }
    } catch (error) {
      console.error('Error creating alert:', error)
      alert('Failed to create alert preference')
    }
  }

  const handleDeleteAlert = async (alertId) => {
    if (!window.confirm('Are you sure you want to delete this alert?')) {
      return
    }

    try {
      const response = await api.post('/api/alert-preferences', {
        action: 'delete',
        alertId: alertId
      }, {
        headers: {
          'Content-Type': 'application/json'
        }
      })

      if (response.data.success) {
        loadAlertPreferences()
      } else {
        alert(response.data.message || 'Failed to delete alert')
      }
    } catch (error) {
      console.error('Error deleting alert:', error)
      alert('Failed to delete alert preference')
    }
  }

  const handleSearch = async (e) => {
    e.preventDefault()
    setLoading(true)

    try {
      const params = new URLSearchParams()
      Object.keys(searchParams).forEach(key => {
        if (searchParams[key]) {
          params.append(key, searchParams[key])
        }
      })

      const response = await api.get(`/api/search?${params.toString()}`)

      let data = response.data
      if (typeof data === 'string') {
        try {
          data = JSON.parse(data)
        } catch (e) {
          console.error('Failed to parse search response:', e)
          data = []
        }
      }
      setItems(Array.isArray(data) ? data : [])
    } catch (error) {
      console.error('Error searching:', error)
      alert('Failed to search items')
    } finally {
      setLoading(false)
    }
  }

  const handlePlaceBid = async (item) => {
    if (!bidAmount || parseFloat(bidAmount) <= 0) {
      alert('Please enter a valid bid amount')
      return
    }

    try {
      const formData = new URLSearchParams()
      const itemType = item.type === 'top' ? 'top' : item.type === 'bottom' ? 'bottom' : 'shoe'
      formData.append('itemType', itemType)
      formData.append('itemId', item.id)
      formData.append('newBid', bidAmount)
      formData.append('autoIncrement', autoIncrement || '')
      formData.append('maxBid', maxBid || '')

      const response = await api.post('/api/bid', formData.toString(), {
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded'
        }
      })

      if (response.data.success) {
        alert('Bid placed successfully!')
        setSelectedItem(null)
        setBidAmount('')

        const params = new URLSearchParams()
        Object.keys(searchParams).forEach(key => {
          if (searchParams[key]) {
            params.append(key, searchParams[key])
          }
        })
        api.get(`/api/search?${params.toString()}`).then(response => {

          let data = response.data
          if (typeof data === 'string') {
            try {
              data = JSON.parse(data)
            } catch (e) {
              console.error('Failed to parse search response:', e)
              data = []
            }
          }
          setItems(Array.isArray(data) ? data : [])
        }).catch(error => {
          console.error('Error refreshing search:', error)
        })
      } else {
        alert(response.data.message || 'Failed to place bid')
      }
    } catch (error) {
      console.error('Error placing bid:', error)
      alert(error.response?.data?.message || 'Failed to place bid')
    }
  }

  const viewBidHistory = (item) => {
    navigate(`/bid-history?itemType=${item.type}&itemId=${item.id}`)
  }

  return (
    <div className="app">
      <Header />
      <div className="container">
        <div className="page-header">
          <h1>Search Items</h1>
          <Link to="/" className="btn btn-outline" style={{marginTop: '1rem'}}>← Back to Main Page</Link>
        </div>

        <form onSubmit={handleSearch} className="search-form" style={{marginBottom: '2rem', padding: '1.5rem', background: 'white', borderRadius: '12px', boxShadow: 'var(--shadow-sm)'}}>
          <div style={{display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '1rem', marginBottom: '1rem'}}>
            <div className="form-group">
              <label>Item Type</label>
              <select
                value={searchParams.itemType}
                onChange={(e) => setSearchParams({...searchParams, itemType: e.target.value})}
                className="form-control"
              >
                <option value="any">Any</option>
                <option value="tops">Tops</option>
                <option value="bottoms">Bottoms</option>
                <option value="shoes">Shoes</option>
              </select>
            </div>

            <div className="form-group">
              <label>Gender</label>
              <select
                value={searchParams.gender}
                onChange={(e) => setSearchParams({...searchParams, gender: e.target.value})}
                className="form-control"
              >
                <option value="">Any Gender</option>
                <option value="Male">Male</option>
                <option value="Female">Female</option>
                <option value="Unisex">Unisex</option>
              </select>
            </div>

            <div className="form-group">
              <label>Size</label>
              <input
                type="text"
                value={searchParams.size}
                onChange={(e) => setSearchParams({...searchParams, size: e.target.value})}
                className="form-control"
                placeholder="Any Size"
              />
            </div>

            <div className="form-group">
              <label>Color</label>
              <input
                type="text"
                value={searchParams.color}
                onChange={(e) => setSearchParams({...searchParams, color: e.target.value})}
                className="form-control"
                placeholder="Any Color"
              />
            </div>

            <div className="form-group">
              <label>Description</label>
              <input
                type="text"
                value={searchParams.description}
                onChange={(e) => setSearchParams({...searchParams, description: e.target.value})}
                className="form-control"
                placeholder="Search description..."
              />
            </div>

            <div className="form-group">
              <label>Condition</label>
              <input
                type="text"
                value={searchParams.condition}
                onChange={(e) => setSearchParams({...searchParams, condition: e.target.value})}
                className="form-control"
                placeholder="Any Condition"
              />
            </div>

            <div className="form-group">
              <label>Min Price</label>
              <input
                type="number"
                value={searchParams.minPrice}
                onChange={(e) => setSearchParams({...searchParams, minPrice: e.target.value})}
                className="form-control"
                step="0.01"
                placeholder="0.00"
              />
            </div>

            <div className="form-group">
              <label>Max Price</label>
              <input
                type="number"
                value={searchParams.maxPrice}
                onChange={(e) => setSearchParams({...searchParams, maxPrice: e.target.value})}
                className="form-control"
                step="0.01"
                placeholder="9999.99"
              />
            </div>

            <div className="form-group">
              <label>Seller</label>
              <input
                type="text"
                value={searchParams.seller}
                onChange={(e) => setSearchParams({...searchParams, seller: e.target.value})}
                className="form-control"
                placeholder="Any Seller"
              />
            </div>

            <div className="form-group">
              <label>Sort By</label>
              <select
                value={searchParams.sortBy}
                onChange={(e) => setSearchParams({...searchParams, sortBy: e.target.value})}
                className="form-control"
              >
                <option value="price">Price</option>
                <option value="date">Closing Date</option>
                <option value="type">Item Type</option>
              </select>
            </div>

            <div className="form-group">
              <label>Sort Order</label>
              <select
                value={searchParams.sortOrder}
                onChange={(e) => setSearchParams({...searchParams, sortOrder: e.target.value})}
                className="form-control"
              >
                <option value="asc">Ascending</option>
                <option value="desc">Descending</option>
              </select>
            </div>
          </div>

          <button type="submit" className="btn btn-primary" disabled={loading}>
            {loading ? 'Searching...' : 'Search'}
          </button>
        </form>

        {}
        <div className="alert-section" style={{ marginTop: '2rem', padding: '1.5rem', border: '2px solid #ddd', borderRadius: '8px', backgroundColor: '#f9f9f9' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1rem' }}>
            <h3>Set Item Alerts</h3>
            <button
              className="btn btn-secondary"
              onClick={() => setShowAlertForm(!showAlertForm)}
              style={{ padding: '0.5rem 1rem' }}
            >
              {showAlertForm ? 'Cancel' : '+ New Alert'}
            </button>
          </div>

          {showAlertForm && (
            <form onSubmit={handleCreateAlert} style={{ marginBottom: '1.5rem', padding: '1rem', backgroundColor: 'white', borderRadius: '6px' }}>
              <h4 style={{ marginBottom: '1rem' }}>Create Alert Preference</h4>
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '1rem' }}>
                <div>
                  <label>Item Type *</label>
                  <select
                    value={alertForm.itemType}
                    onChange={(e) => setAlertForm({...alertForm, itemType: e.target.value})}
                    className="form-control"
                    required
                  >
                    <option value="top">Top</option>
                    <option value="bottom">Bottom</option>
                    <option value="shoe">Shoe</option>
                  </select>
                </div>
                <div>
                  <label>Gender (optional)</label>
                  <input
                    type="text"
                    value={alertForm.gender}
                    onChange={(e) => setAlertForm({...alertForm, gender: e.target.value})}
                    className="form-control"
                    placeholder="Any"
                  />
                </div>
                <div>
                  <label>Size (optional)</label>
                  <input
                    type="text"
                    value={alertForm.size}
                    onChange={(e) => setAlertForm({...alertForm, size: e.target.value})}
                    className="form-control"
                    placeholder="Any"
                  />
                </div>
                <div>
                  <label>Color (optional)</label>
                  <input
                    type="text"
                    value={alertForm.color}
                    onChange={(e) => setAlertForm({...alertForm, color: e.target.value})}
                    className="form-control"
                    placeholder="Any"
                  />
                </div>
              </div>
              <button type="submit" className="btn btn-primary" style={{ marginTop: '1rem' }}>
                Create Alert
              </button>
            </form>
          )}

          {alertPreferences.length > 0 && (
            <div>
              <h4 style={{ marginBottom: '0.5rem' }}>Your Active Alerts ({alertPreferences.length})</h4>
              <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
                {alertPreferences.map((alert) => (
                  <div key={alert.alertId} style={{
                    padding: '0.75rem',
                    backgroundColor: 'white',
                    borderRadius: '4px',
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center'
                  }}>
                    <div>
                      <strong>{alert.itemType}</strong>
                      {alert.gender && ` • Gender: ${alert.gender}`}
                      {alert.size && ` • Size: ${alert.size}`}
                      {alert.color && ` • Color: ${alert.color}`}
                    </div>
                    <button
                      className="btn btn-danger"
                      onClick={() => handleDeleteAlert(alert.alertId)}
                      style={{ padding: '0.25rem 0.75rem', fontSize: '0.875rem' }}
                    >
                      Delete
                    </button>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>

        {Array.isArray(items) && items.length > 0 && (
          <div className="items-grid">
            {items.map((item, index) => {
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
                <div key={`${item.type}-${item.id}`} className={`item-card ${auctionClosed ? 'auction-closed' : ''}`}>
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
                      onClick={() => viewBidHistory(item)}
                    >
                      Bid History
                    </button>
                  </div>
                </div>
              )
            })}
          </div>
        )}

        {items.length === 0 && !loading && (
          <div className="no-items">
            <p>No items found. Try adjusting your search criteria.</p>
          </div>
        )}

        {selectedItem && (
          <div className="bid-modal-overlay" onClick={() => setSelectedItem(null)}>
            <div className="bid-modal" onClick={(e) => e.stopPropagation()}>
              <span className="modal-close" onClick={() => setSelectedItem(null)}>&times;</span>
              <h2>Place Bid on {selectedItem.description || `${selectedItem.type} #${selectedItem.id}`}</h2>
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
                  onClick={() => handlePlaceBid(selectedItem)}
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

export default Search

