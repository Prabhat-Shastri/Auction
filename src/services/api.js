import axios from 'axios'

const api = axios.create({
  baseURL: 'http://localhost:8080/ThriftShop',
  withCredentials: true,
  timeout: 10000,
})


api.interceptors.request.use(
  config => {
    console.log('API Request:', config.method?.toUpperCase(), config.url, config.data)
    return config
  },
  error => {
    console.error('API Request Error:', error)
    return Promise.reject(error)
  }
)


api.interceptors.response.use(
  response => {
    console.log('API Response:', response.status, typeof response.data, response.data)


    const contentType = response.headers['content-type'] || response.headers['Content-Type'] || ''
    if (typeof response.data === 'string' &&
        response.data.trim().startsWith('{') &&
        !contentType.includes('application/json') &&
        typeof response.data !== 'object') {
      try {
        response.data = JSON.parse(response.data)
        console.log('Parsed JSON successfully:', response.data)
      } catch (e) {

        console.warn('Failed to parse JSON response:', e.message, response.data.substring(0, 100))
      }
    }
    return response
  },
  error => {
    console.error('API Error:', error.message)
    console.error('API Error Response:', error.response)


    if (!error.response) {
      console.error('Network error - is Tomcat running?')
      error.message = 'Network error: Cannot connect to server. Make sure Tomcat is running on port 8080.'
    }


    if (error.response && typeof error.response.data === 'string') {
      try {
        error.response.data = JSON.parse(error.response.data)
      } catch (e) {

      }
    }
    return Promise.reject(error)
  }
)

export default api

