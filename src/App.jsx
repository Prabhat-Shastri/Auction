import React from 'react'
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import { AuthProvider, useAuth } from './context/AuthContext'
import Login from './pages/Login'
import Register from './pages/Register'
import MainPage from './pages/MainPage'
import Tops from './pages/Tops'
import Bottoms from './pages/Bottoms'
import Shoes from './pages/Shoes'
import Search from './pages/Search'
import BidHistory from './pages/BidHistory'
import MyAuctions from './pages/MyAuctions'
import UserAuctions from './pages/UserAuctions'
import Notifications from './pages/Notifications'
import AdminLogin from './pages/AdminLogin'
import AdminDashboard from './pages/AdminDashboard'
import CustomerRepLogin from './pages/CustomerRepLogin'
import CustomerRepDashboard from './pages/CustomerRepDashboard'
import FAQs from './pages/FAQs'
import './App.css'

function PrivateRoute({ children }) {
  const { user } = useAuth()
  return user ? children : <Navigate to="/login" />
}

function App() {
  return (
    <AuthProvider>
      <Router>
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route path="/register" element={<Register />} />
          <Route path="/admin/login" element={<AdminLogin />} />
          <Route path="/admin/dashboard" element={<AdminDashboard />} />
          <Route path="/customer-rep/login" element={<CustomerRepLogin />} />
          <Route path="/customer-rep/dashboard" element={<CustomerRepDashboard />} />
          <Route path="/faqs" element={<PrivateRoute><FAQs /></PrivateRoute>} />
          <Route path="/" element={<PrivateRoute><MainPage /></PrivateRoute>} />
          <Route path="/tops" element={<PrivateRoute><Tops /></PrivateRoute>} />
          <Route path="/bottoms" element={<PrivateRoute><Bottoms /></PrivateRoute>} />
          <Route path="/shoes" element={<PrivateRoute><Shoes /></PrivateRoute>} />
          <Route path="/search" element={<PrivateRoute><Search /></PrivateRoute>} />
          <Route path="/bid-history" element={<PrivateRoute><BidHistory /></PrivateRoute>} />
          <Route path="/my-auctions" element={<PrivateRoute><MyAuctions /></PrivateRoute>} />
          <Route path="/user-auctions" element={<PrivateRoute><UserAuctions /></PrivateRoute>} />
          <Route path="/notifications" element={<PrivateRoute><Notifications /></PrivateRoute>} />
        </Routes>
      </Router>
    </AuthProvider>
  )
}

export default App

