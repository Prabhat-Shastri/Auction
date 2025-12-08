import React, { useState, useEffect } from 'react'
import { useAuth } from '../context/AuthContext'
import api from '../services/api'
import Header from '../components/Header'
import './FAQs.css'

function FAQs() {
  const { user } = useAuth()
  const [faqs, setFaqs] = useState([])
  const [searchQuery, setSearchQuery] = useState('')
  const [newQuestion, setNewQuestion] = useState('')
  const [loading, setLoading] = useState(false)
  const [message, setMessage] = useState('')

  useEffect(() => {
    loadFaqs()
  }, [searchQuery])

  const loadFaqs = async () => {
    setLoading(true)
    try {
      const url = '/api/faqs' + (searchQuery ? `?search=${encodeURIComponent(searchQuery)}` : '')
      const response = await api.get(url)

      let faqsData = response.data
      if (typeof faqsData === 'string') {
        try {
          faqsData = JSON.parse(faqsData)
        } catch (e) {
          console.error('Failed to parse FAQs JSON:', e)
          return
        }
      }

      setFaqs(Array.isArray(faqsData) ? faqsData : [])
    } catch (error) {
      console.error('Error loading FAQs:', error)
      setFaqs([])
    } finally {
      setLoading(false)
    }
  }

  const handlePostQuestion = async (e) => {
    e.preventDefault()
    if (!newQuestion.trim()) {
      setMessage('Please enter a question')
      return
    }

    if (!user) {
      setMessage('Please login to post a question')
      return
    }

    setLoading(true)
    setMessage('')

    try {
      const formData = new URLSearchParams()
      formData.append('question', newQuestion)

      const response = await api.post('/api/faqs', formData.toString(), {
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded'
        }
      })

      if (response.data.success) {
        setMessage('Question posted successfully!')
        setNewQuestion('')
        loadFaqs()
      } else {
        setMessage(response.data.message || 'Failed to post question')
      }
    } catch (error) {
      console.error('Error posting question:', error)
      setMessage('Failed to post question')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="faqs-page">
      <Header />
      <div className="faqs-container">
        <h1>Frequently Asked Questions</h1>

        <div className="search-section">
          <input
            type="text"
            placeholder="Search questions and answers..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="search-input"
          />
        </div>

        {user && (
          <div className="post-question-section">
            <h2>Ask a Question</h2>
            <form onSubmit={handlePostQuestion}>
              <textarea
                value={newQuestion}
                onChange={(e) => setNewQuestion(e.target.value)}
                placeholder="Type your question here..."
                rows="4"
                className="question-input"
                required
              />
              <button type="submit" className="btn btn-primary" disabled={loading}>
                {loading ? 'Posting...' : 'Post Question'}
              </button>
            </form>
            {message && <div className={`message ${message.toLowerCase().includes('success') ? 'success' : 'error'}`}>{message}</div>}
          </div>
        )}

        <div className="faqs-list">
          <h2>Questions & Answers</h2>
          {loading && <p>Loading...</p>}
          {!loading && faqs.length === 0 && (
            <p className="no-faqs">No FAQs found. {searchQuery && 'Try a different search term.'}</p>
          )}
          {!loading && faqs.map((faq) => (
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
                <div className="faq-pending">Waiting for customer service response...</div>
              )}
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}

export default FAQs

