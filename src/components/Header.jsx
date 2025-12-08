import React from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import './Header.css'

function Header() {
  const { user, logout } = useAuth()
  const navigate = useNavigate()

  const handleLogout = () => {
    logout()
    navigate('/login')
  }

  return (
    <header className="header">
      <div className="header-container">
        <Link to="/" className="logo">ThriftShop</Link>
        <nav>
          <ul className="nav-menu">
            <li><Link to="/tops">Tops</Link></li>
            <li><Link to="/bottoms">Bottoms</Link></li>
            <li><Link to="/shoes">Shoes</Link></li>
            <li><Link to="/faqs">FAQs</Link></li>
            <li><Link to="/notifications">Notifications</Link></li>
            <li><Link to="/user-auctions?role=buyer">My Bids</Link></li>
            <li><a href="#" onClick={handleLogout}>Logout</a></li>
          </ul>
        </nav>
        <div className="user-info">{user?.username}</div>
      </div>
    </header>
  )
}

export default Header

