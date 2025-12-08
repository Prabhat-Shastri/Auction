import React, { useState, useEffect } from 'react'
import { Link, useSearchParams, useNavigate } from 'react-router-dom'
import Header from '../components/Header'
import api from '../services/api'
import './BidHistory.css'
import './Tops.css'

function BidHistory() {
  const [searchParams] = useSearchParams()
  const [item, setItem] = useState(null)
  const [bids, setBids] = useState([])
  const [similarItems, setSimilarItems] = useState([])
  const [loading, setLoading] = useState(true)
  const [currentUserId, setCurrentUserId] = useState(null)
  const navigate = useNavigate()

  useEffect(() => {

    const userId = sessionStorage.getItem('userId')
    if (userId) {
      setCurrentUserId(parseInt(userId))
    }

    const itemType = searchParams.get('itemType')
    const itemId = searchParams.get('itemId')

    if (itemType && itemId) {
      fetchBidHistory(itemType, itemId)
    } else {
      setLoading(false)
    }
  }, [searchParams])

  const fetchBidHistory = async (itemType, itemId) => {
    try {
      const response = await api.get(`/api/bid-history?itemType=${itemType}&itemId=${itemId}`)
      setItem(response.data.item)
      setBids(response.data.bids || [])


      try {
        const similarResponse = await api.get(`/api/similar-items?itemType=${itemType}&itemId=${itemId}`)
        setSimilarItems(similarResponse.data || [])
      } catch (err) {
        console.error('Error fetching similar items:', err)
      }
    } catch (error) {
      console.error('Error fetching bid history:', error)
      alert('Failed to load bid history')
    } finally {
      setLoading(false)
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

  if (!item) {
    return (
      <div className="app">
        <Header />
        <div className="container">
          <p style={{color: 'red'}}>No item selected.</p>
          <Link to="/" className="btn btn-outline">← Back to Main Page</Link>
        </div>
      </div>
    )
  }

  return (
    <div className="app">
      <Header />
      <div className="container">
        <div className="page-header">
          <h1>Bid History</h1>
          <Link to="/" className="btn btn-outline" style={{marginTop: '1rem'}}>← Back to Main Page</Link>
        </div>

        <div className="item-info-card">
          <h2>{item.description || `${item.type} #${item.id}`}</h2>
          <div className="item-details">
            <p><strong>Seller:</strong> {item.sellerUsername}</p>
            <p><strong>Gender:</strong> {item.gender}</p>
            <p><strong>Size:</strong> {item.size}</p>
            <p><strong>Color:</strong> {item.color}</p>
            <p><strong>Description:</strong> {item.description}</p>
            <p><strong>Condition:</strong> {item.condition}</p>
            <p><strong>Current Bid:</strong> ${item.currentBidPrice.toFixed(2)}</p>
            <p><strong>Closes:</strong> {item.closeDate} at {item.closeTime}</p>
          </div>
        </div>

        <div className="bid-history-section">
          <h2>Bid History</h2>
          {bids.length === 0 ? (
            <p>No bids yet.</p>
          ) : (
            <table className="bid-table">
              <thead>
                <tr>
                  <th>Bid ID</th>
                  <th>Buyer</th>
                  <th>Bid Amount</th>
                  {currentUserId && bids.some(bid => bid.buyerId === currentUserId && (bid.bidIncrement || bid.maxBid)) && (
                    <>
                      <th>Auto Increment</th>
                      <th>Max Bid</th>
                    </>
                  )}
                </tr>
              </thead>
              <tbody>
                {bids.map((bid) => {
                  const isOwnBid = currentUserId && bid.buyerId === currentUserId
                  const showAutoBidColumns = currentUserId && bids.some(b => b.buyerId === currentUserId && (b.bidIncrement || b.maxBid))
                  return (
                    <tr key={bid.bidId}>
                      <td>{bid.bidId}</td>
                      <td>{bid.buyerUsername}</td>
                      <td>${bid.bidAmount.toFixed(2)}</td>
                      {showAutoBidColumns && (
                        <>
                          {isOwnBid ? (
                            <>
                              <td>{bid.bidIncrement || '-'}</td>
                              <td>{bid.maxBid || '-'}</td>
                            </>
                          ) : (
                            <>
                              <td>-</td>
                              <td>-</td>
                            </>
                          )}
                        </>
                      )}
                    </tr>
                  )
                })}
              </tbody>
            </table>
          )}
        </div>

        {similarItems.length > 0 && (
          <div className="similar-items-section" style={{marginTop: '2rem'}}>
            <h2>Similar Items (From Preceding Month)</h2>
            <div className="items-grid">
              {similarItems.map((similarItem) => (
                <div key={`${similarItem.type}-${similarItem.id}`} className="item-card">
                  <div className="item-image">
                    {(() => {

                      const images = similarItem.images && similarItem.images.length > 0
                        ? similarItem.images
                        : (similarItem.imagePath ? [similarItem.imagePath] : []);


                      if (images.length === 0) {
                        return <span>No Image</span>;
                      }

                      if (images.length === 1) {
                        return <img src={`/ThriftShop/Images/${images[0]}`} alt={similarItem.description} />;
                      }


                      return (
                        <div className="image-gallery">
                          <img src={`/ThriftShop/Images/${images[0]}`} alt={similarItem.description} className="main-image" />
                          <div className="image-thumbnails">
                            {images.slice(1, 4).map((img, idx) => (
                              <img
                                key={idx}
                                src={`/ThriftShop/Images/${img}`}
                                alt={`${similarItem.description} ${idx + 2}`}
                                className="thumbnail"
                              />
                            ))}
                            {images.length > 4 && (
                              <div className="thumbnail more-images">+{images.length - 4}</div>
                            )}
                          </div>
                        </div>
                      );
                    })()}
                  </div>
                  <div className="item-body">
                    <div className="item-title">
                      {similarItem.description || `${similarItem.type} #${similarItem.id}`}
                    </div>
                    <div className="item-meta">
                      <span>Type: {similarItem.type}</span> |
                      <span> Seller: {similarItem.sellerUsername}</span> |
                      <span> {similarItem.gender}</span> |
                      <span> Size: {similarItem.size}</span> |
                      <span> Color: {similarItem.color}</span>
                    </div>
                    <p><strong>Description:</strong> {similarItem.description}</p>
                    <p><strong>Condition:</strong> {similarItem.condition}</p>
                    <div className="item-price">
                      Current Bid: ${similarItem.currentBidPrice.toFixed(2)}
                    </div>
                    <p className="close-time">
                      <strong>⏰ Closes:</strong> {similarItem.closeDate} at {similarItem.closeTime}
                    </p>
                  </div>
                  <div className="item-footer">
                    <button
                      className="btn btn-secondary"
                      onClick={() => navigate(`/bid-history?itemType=${similarItem.type}&itemId=${similarItem.id}`)}
                    >
                      View Bid History
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  )
}

export default BidHistory

