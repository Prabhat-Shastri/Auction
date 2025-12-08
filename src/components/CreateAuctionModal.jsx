import React, { useState } from 'react'
import api from '../services/api'
import './CreateAuctionModal.css'

function CreateAuctionModal({ isOpen, onClose }) {
  const [itemType, setItemType] = useState('')
  const [formData, setFormData] = useState({})
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  if (!isOpen) return null

  const handleSubmit = async (e) => {
    e.preventDefault()
    setLoading(true)
    setError('')


    if (formData.closeDate && formData.closeTime) {

      const [year, month, day] = formData.closeDate.split('-').map(Number)
      const [hours, minutes] = formData.closeTime.split(':').map(Number)


      const closeDateTime = new Date(year, month - 1, day, hours, minutes, 0, 0)


      const now = new Date()


      const buffer = new Date(now.getTime() + 1000)

      if (closeDateTime <= buffer) {
        setError('Auction close date and time must be in the future (at least 1 second from now)')
        setLoading(false)
        return
      }
    }

    try {
      const formDataToSend = new FormData()
      Object.keys(formData).forEach(key => {
        if (formData[key] !== null && formData[key] !== undefined && formData[key] !== '') {
          formDataToSend.append(key, formData[key])
        }
      })


      if (itemType === 'tops') {
        formDataToSend.append('gender', formData.gender)
        formDataToSend.append('size', formData.size)
        formDataToSend.append('color', formData.color)
        formDataToSend.append('frontLength', formData.frontLength)
        formDataToSend.append('chestLength', formData.chestLength)
        formDataToSend.append('sleeveLength', formData.sleeveLength)
        formDataToSend.append('description', formData.description)
        formDataToSend.append('condition', formData.condition)
        formDataToSend.append('minimumBidPrice', formData.minimumBidPrice)
        formDataToSend.append('startingBidPrice', formData.startingBidPrice)
        formDataToSend.append('closeDate', formData.closeDate)
        formDataToSend.append('closeTime', formData.closeTime)

        if (formData.image) {
          if (Array.isArray(formData.image)) {
            formData.image.forEach((file, index) => {
              formDataToSend.append('images', file)
            })
          } else {
            formDataToSend.append('image', formData.image)
          }
        }
      } else if (itemType === 'bottoms') {
        formDataToSend.append('gender', formData.gender)
        formDataToSend.append('size', formData.size)
        formDataToSend.append('color', formData.color)
        formDataToSend.append('waistLength', formData.waistLength)
        formDataToSend.append('inseamLength', formData.inseamLength)
        formDataToSend.append('outseamLength', formData.outseamLength)
        formDataToSend.append('hipLength', formData.hipLength)
        formDataToSend.append('riseLength', formData.riseLength)
        formDataToSend.append('description', formData.description)
        formDataToSend.append('condition', formData.condition)
        formDataToSend.append('minimumBidPrice', formData.minimumBidPrice)
        formDataToSend.append('startingBidPrice', formData.startingBidPrice)
        formDataToSend.append('closeDate', formData.closeDate)
        formDataToSend.append('closeTime', formData.closeTime)

        if (formData.image) {
          if (Array.isArray(formData.image)) {
            formData.image.forEach((file, index) => {
              formDataToSend.append('images', file)
            })
          } else {
            formDataToSend.append('image', formData.image)
          }
        }
      } else if (itemType === 'shoes') {
        formDataToSend.append('gender', formData.gender)
        formDataToSend.append('size', formData.size)
        formDataToSend.append('color', formData.color)
        formDataToSend.append('description', formData.description)
        formDataToSend.append('condition', formData.condition)
        formDataToSend.append('minimumBidPrice', formData.minimumBidPrice)
        formDataToSend.append('startingBidPrice', formData.startingBidPrice)
        formDataToSend.append('closeDate', formData.closeDate)
        formDataToSend.append('closeTime', formData.closeTime)

        if (formData.image) {
          if (Array.isArray(formData.image)) {
            formData.image.forEach((file, index) => {
              formDataToSend.append('images', file)
            })
          } else {
            formDataToSend.append('image', formData.image)
          }
        }
      }


      const response = await api.post(`/api/auctions/${itemType}`, formDataToSend)

      if (response.data.success) {
        alert('Auction created successfully!')
        setFormData({})
        setItemType('')
        setError('')
        onClose()


      } else {
        setError(response.data.message || 'Failed to create auction')
      }
    } catch (err) {
      console.error('Error creating auction:', err)
      console.error('Error response:', err.response)
      console.error('Error data:', err.response?.data)
      const errorMessage = err.response?.data?.message || err.message || 'Failed to create auction'
      setError(errorMessage)
    } finally {
      setLoading(false)
    }
  }

  const handleChange = (e) => {
    if (e.target.type === 'file') {

      const files = Array.from(e.target.files)
      setFormData({
        ...formData,
        [e.target.name]: files.length === 1 ? files[0] : files
      })
    } else {
      setFormData({
        ...formData,
        [e.target.name]: e.target.value
      })
    }
  }

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-content" onClick={(e) => e.stopPropagation()}>
        <span className="modal-close" onClick={onClose}>&times;</span>
        <div className="modal-header">
          <h2>Create New Auction</h2>
        </div>
        <form onSubmit={handleSubmit} className="auction-form">
          {error && <div className="error-message" style={{background: '#fee', color: '#e74c3c', padding: '0.75rem', borderRadius: '8px', marginBottom: '1rem'}}>{error}</div>}

          <div className="form-group">
            <label htmlFor="itemsType">Choose Item Type</label>
            <select
              id="itemsType"
              name="itemsType"
              value={itemType}
              onChange={(e) => {
                setItemType(e.target.value)
                setFormData({})
              }}
              required
              className="form-control"
            >
              <option value="">Select Item...</option>
              <option value="tops">Tops</option>
              <option value="bottoms">Bottoms</option>
              <option value="shoes">Shoes</option>
            </select>
          </div>

          {itemType === 'tops' && (
            <TopsForm formData={formData} handleChange={handleChange} />
          )}
          {itemType === 'bottoms' && (
            <BottomsForm formData={formData} handleChange={handleChange} />
          )}
          {itemType === 'shoes' && (
            <ShoesForm formData={formData} handleChange={handleChange} />
          )}

          {itemType && (
            <button type="submit" className="btn btn-primary" disabled={loading}>
              {loading ? 'Creating...' : 'Create Auction'}
            </button>
          )}
        </form>
      </div>
    </div>
  )
}

function TopsForm({ formData, handleChange }) {
  return (
    <div className="form-row">
      <div className="form-group">
        <label>Gender</label>
        <select name="gender" value={formData.gender || ''} onChange={handleChange} required className="form-control">
          <option value="">Select Gender...</option>
          <option value="Male">Male</option>
          <option value="Female">Female</option>
          <option value="Unisex">Unisex</option>
        </select>
      </div>
      <div className="form-group">
        <label>Size</label>
        <select name="size" value={formData.size || ''} onChange={handleChange} required className="form-control">
          <option value="">Select Size...</option>
          <option value="XS">XS</option>
          <option value="S">S</option>
          <option value="M">M</option>
          <option value="L">L</option>
          <option value="XL">XL</option>
          <option value="XXL">XXL</option>
        </select>
      </div>
      <div className="form-group">
        <label>Color</label>
        <select name="color" value={formData.color || ''} onChange={handleChange} required className="form-control">
          <option value="">Select Color...</option>
          <option value="Black">Black</option>
          <option value="Blue">Blue</option>
          <option value="Gray">Gray</option>
          <option value="White">White</option>
          <option value="Brown">Brown</option>
          <option value="Red">Red</option>
          <option value="Pink">Pink</option>
          <option value="Orange">Orange</option>
          <option value="Yellow">Yellow</option>
          <option value="Green">Green</option>
          <option value="Purple">Purple</option>
        </select>
      </div>
      <div className="form-group">
        <label>Front Length (cm)</label>
        <input type="number" name="frontLength" value={formData.frontLength || ''} onChange={handleChange} min="0" required className="form-control" />
      </div>
      <div className="form-group">
        <label>Chest Length (cm)</label>
        <input type="number" name="chestLength" value={formData.chestLength || ''} onChange={handleChange} min="0" required className="form-control" />
      </div>
      <div className="form-group">
        <label>Sleeve Length (cm)</label>
        <input type="number" name="sleeveLength" value={formData.sleeveLength || ''} onChange={handleChange} min="0" required className="form-control" />
      </div>
      <div className="form-group">
        <label>Description</label>
        <input type="text" name="description" value={formData.description || ''} onChange={handleChange} maxLength="200" required className="form-control" />
      </div>
      <div className="form-group">
        <label>Condition</label>
        <input type="text" name="condition" value={formData.condition || ''} onChange={handleChange} maxLength="200" required className="form-control" />
      </div>
      <div className="form-group">
        <label>Reserve Price (USD) - Hidden from buyers</label>
        <input type="number" name="minimumBidPrice" value={formData.minimumBidPrice || ''} onChange={handleChange} min="0" step="0.01" required className="form-control" />
      </div>
      <div className="form-group">
        <label>Starting Bid Price (USD)</label>
        <input type="number" name="startingBidPrice" value={formData.startingBidPrice || ''} onChange={handleChange} min="0" step="0.01" required className="form-control" />
      </div>
      <div className="form-group">
        <label>Auction Close Date</label>
        <input type="date" name="closeDate" value={formData.closeDate || ''} onChange={handleChange} required className="form-control" />
      </div>
      <div className="form-group">
        <label>Auction Close Time</label>
        <input
          type="time"
          name="closeTime"
          value={formData.closeTime || ''}
          onChange={handleChange}
          required
          className="form-control"
          min={formData.closeDate === new Date().toISOString().split('T')[0] ? new Date().toTimeString().slice(0, 5) : undefined}
        />
      </div>
      <div className="form-group">
        <label>Item Images (optional - you can select multiple)</label>
        <input type="file" name="image" accept="image/*" multiple onChange={handleChange} className="form-control" />
        {formData.image && (
          <small style={{color: '#666', display: 'block', marginTop: '0.5rem'}}>
            {Array.isArray(formData.image)
              ? `${formData.image.length} image(s) selected`
              : '1 image selected'}
          </small>
        )}
      </div>
    </div>
  )
}

function BottomsForm({ formData, handleChange }) {
  return (
    <div className="form-row">
      <div className="form-group">
        <label>Gender</label>
        <select name="gender" value={formData.gender || ''} onChange={handleChange} required className="form-control">
          <option value="">Select Gender...</option>
          <option value="Male">Male</option>
          <option value="Female">Female</option>
          <option value="Unisex">Unisex</option>
        </select>
      </div>
      <div className="form-group">
        <label>Size</label>
        <select name="size" value={formData.size || ''} onChange={handleChange} required className="form-control">
          <option value="">Select Size...</option>
          <option value="XS">XS</option>
          <option value="S">S</option>
          <option value="M">M</option>
          <option value="L">L</option>
          <option value="XL">XL</option>
          <option value="XXL">XXL</option>
        </select>
      </div>
      <div className="form-group">
        <label>Color</label>
        <select name="color" value={formData.color || ''} onChange={handleChange} required className="form-control">
          <option value="">Select Color...</option>
          <option value="Black">Black</option>
          <option value="Blue">Blue</option>
          <option value="Gray">Gray</option>
          <option value="White">White</option>
          <option value="Brown">Brown</option>
          <option value="Red">Red</option>
          <option value="Pink">Pink</option>
          <option value="Orange">Orange</option>
          <option value="Yellow">Yellow</option>
          <option value="Green">Green</option>
          <option value="Purple">Purple</option>
        </select>
      </div>
      <div className="form-group">
        <label>Waist Length (cm)</label>
        <input type="number" name="waistLength" value={formData.waistLength || ''} onChange={handleChange} min="0" required className="form-control" />
      </div>
      <div className="form-group">
        <label>Inseam Length (cm)</label>
        <input type="number" name="inseamLength" value={formData.inseamLength || ''} onChange={handleChange} min="0" required className="form-control" />
      </div>
      <div className="form-group">
        <label>Outseam Length (cm)</label>
        <input type="number" name="outseamLength" value={formData.outseamLength || ''} onChange={handleChange} min="0" required className="form-control" />
      </div>
      <div className="form-group">
        <label>Hip Length (cm)</label>
        <input type="number" name="hipLength" value={formData.hipLength || ''} onChange={handleChange} min="0" required className="form-control" />
      </div>
      <div className="form-group">
        <label>Rise Length (cm)</label>
        <input type="number" name="riseLength" value={formData.riseLength || ''} onChange={handleChange} min="0" required className="form-control" />
      </div>
      <div className="form-group">
        <label>Description</label>
        <input type="text" name="description" value={formData.description || ''} onChange={handleChange} required className="form-control" />
      </div>
      <div className="form-group">
        <label>Condition</label>
        <input type="text" name="condition" value={formData.condition || ''} onChange={handleChange} required className="form-control" />
      </div>
      <div className="form-group">
        <label>Reserve Price (USD)</label>
        <input type="number" name="minimumBidPrice" value={formData.minimumBidPrice || ''} onChange={handleChange} min="0" step="0.01" required className="form-control" />
      </div>
      <div className="form-group">
        <label>Starting Bid Price (USD)</label>
        <input type="number" name="startingBidPrice" value={formData.startingBidPrice || ''} onChange={handleChange} min="0" step="0.01" required className="form-control" />
      </div>
      <div className="form-group">
        <label>Auction Close Date</label>
        <input type="date" name="closeDate" value={formData.closeDate || ''} onChange={handleChange} required className="form-control" />
      </div>
      <div className="form-group">
        <label>Auction Close Time</label>
        <input
          type="time"
          name="closeTime"
          value={formData.closeTime || ''}
          onChange={handleChange}
          required
          className="form-control"
          min={formData.closeDate === new Date().toISOString().split('T')[0] ? new Date().toTimeString().slice(0, 5) : undefined}
        />
      </div>
      <div className="form-group">
        <label>Item Images (optional - you can select multiple)</label>
        <input type="file" name="image" accept="image/*" multiple onChange={handleChange} className="form-control" />
        {formData.image && (
          <small style={{color: '#666', display: 'block', marginTop: '0.5rem'}}>
            {Array.isArray(formData.image)
              ? `${formData.image.length} image(s) selected`
              : '1 image selected'}
          </small>
        )}
      </div>
    </div>
  )
}

function ShoesForm({ formData, handleChange }) {
  return (
    <div className="form-row">
      <div className="form-group">
        <label>Gender</label>
        <select name="gender" value={formData.gender || ''} onChange={handleChange} required className="form-control">
          <option value="">Select Gender...</option>
          <option value="Male">Male</option>
          <option value="Female">Female</option>
          <option value="Unisex">Unisex</option>
        </select>
      </div>
      <div className="form-group">
        <label>Shoe Size</label>
        <input type="number" name="size" value={formData.size || ''} onChange={handleChange} min="0" step="0.5" required className="form-control" />
      </div>
      <div className="form-group">
        <label>Color</label>
        <select name="color" value={formData.color || ''} onChange={handleChange} required className="form-control">
          <option value="">Select Color...</option>
          <option value="Black">Black</option>
          <option value="Blue">Blue</option>
          <option value="Gray">Gray</option>
          <option value="White">White</option>
          <option value="Brown">Brown</option>
          <option value="Red">Red</option>
          <option value="Pink">Pink</option>
          <option value="Orange">Orange</option>
          <option value="Yellow">Yellow</option>
          <option value="Green">Green</option>
          <option value="Purple">Purple</option>
        </select>
      </div>
      <div className="form-group">
        <label>Description</label>
        <input type="text" name="description" value={formData.description || ''} onChange={handleChange} maxLength="200" required className="form-control" />
      </div>
      <div className="form-group">
        <label>Condition</label>
        <input type="text" name="condition" value={formData.condition || ''} onChange={handleChange} maxLength="200" required className="form-control" />
      </div>
      <div className="form-group">
        <label>Reserve Price (USD)</label>
        <input type="number" name="minimumBidPrice" value={formData.minimumBidPrice || ''} onChange={handleChange} min="0" step="0.01" required className="form-control" />
      </div>
      <div className="form-group">
        <label>Starting Bid Price (USD)</label>
        <input type="number" name="startingBidPrice" value={formData.startingBidPrice || ''} onChange={handleChange} min="0" step="0.01" required className="form-control" />
      </div>
      <div className="form-group">
        <label>Auction Close Date</label>
        <input type="date" name="closeDate" value={formData.closeDate || ''} onChange={handleChange} required className="form-control" />
      </div>
      <div className="form-group">
        <label>Auction Close Time</label>
        <input
          type="time"
          name="closeTime"
          value={formData.closeTime || ''}
          onChange={handleChange}
          required
          className="form-control"
          min={formData.closeDate === new Date().toISOString().split('T')[0] ? new Date().toTimeString().slice(0, 5) : undefined}
        />
      </div>
      <div className="form-group">
        <label>Item Images (optional - you can select multiple)</label>
        <input type="file" name="image" accept="image/*" multiple onChange={handleChange} className="form-control" />
        {formData.image && (
          <small style={{color: '#666', display: 'block', marginTop: '0.5rem'}}>
            {Array.isArray(formData.image)
              ? `${formData.image.length} image(s) selected`
              : '1 image selected'}
          </small>
        )}
      </div>
    </div>
  )
}

export default CreateAuctionModal

