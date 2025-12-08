import React, { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import Header from '../components/Header'
import CreateAuctionModal from '../components/CreateAuctionModal'
import api from '../services/api'
import './MainPage.css'

function MainPage() {
  const [isModalOpen, setIsModalOpen] = useState(false)
  const navigate = useNavigate()

  useEffect(() => {

    api.get('/api/check-winners').catch(err => console.error('Error checking winners:', err))


    const interval = setInterval(() => {
      api.get('/api/check-winners').catch(err => console.error('Error checking winners:', err))
    }, 30000)

    return () => clearInterval(interval)
  }, [])

  return (
    <div className="app">
      <Header />

      <div className="banner-container">
        <img src="/banner.jpg" alt="ThriftShop Auction Banner" className="banner-image" />
        <div className="banner-overlay">
          <div className="banner-content">
            <h1>Group 22 - ThriftShop</h1>
            <p>our best try at being able to replicate eBay 🤪</p>
            <div className="banner-buttons">
              <button
                className="btn btn-secondary"
                onClick={() => navigate('/search')}
              >
                Search Items
              </button>
              <button
                className="btn btn-primary"
                onClick={() => setIsModalOpen(true)}
              >
                Create Auction
              </button>
            </div>
          </div>
        </div>
      </div>

      <div className="container">
        <div className="browse-section">
          <h2 className="browse-title">Browse</h2>
          <div className="browse-grid">
            <div className="browse-card" onClick={() => navigate('/tops')}>
              <img src="/tops.jpg" alt="Tops" className="browse-image" />
              <div className="browse-label">Tops</div>
            </div>
            <div className="browse-card" onClick={() => navigate('/bottoms')}>
              <img src="/bottom.jpg" alt="Bottoms" className="browse-image" />
              <div className="browse-label">Bottoms</div>
            </div>
            <div className="browse-card" onClick={() => navigate('/shoes')}>
              <img src="/shoe.jpg" alt="Shoes" className="browse-image" />
              <div className="browse-label">Shoes</div>
            </div>
          </div>
        </div>

        <div className="search-prompt">
          <h2>Know what you are looking for?</h2>
          <p className="search-subtext">If you don't find what you are looking for, you can also set alerts and we will notify you</p>
          <button
            className="btn btn-large btn-secondary"
            onClick={() => navigate('/search')}
          >
            Search Items
          </button>
        </div>

        <div className="search-prompt">
          <h2>Are you here to sell?</h2>
          <p className="search-subtext">Create your first auction here:-</p>
          <button
            className="btn btn-large btn-primary"
            onClick={() => setIsModalOpen(true)}
          >
            Create Auction
          </button>
        </div>

        <CreateAuctionModal
          isOpen={isModalOpen}
          onClose={() => setIsModalOpen(false)}
        />
      </div>
    </div>
  )
}

export default MainPage

