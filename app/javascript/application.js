// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

document.addEventListener('turbo:load', function() {
  if (document.body.dataset.trackVisit === 'true') {
    const accessLogId = document.body.dataset.accessLogId
    if (!accessLogId) return

    function sendExitData() {
      const formData = new FormData()
      formData.append('access_log_id', accessLogId)
      
      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')
      if (csrfToken) {
        formData.append('authenticity_token', csrfToken)
      }
      
      navigator.sendBeacon('/track_exit', formData)
    }

    window.addEventListener('beforeunload', function(e) {
      sendExitData()
    })

    document.addEventListener('visibilitychange', function() {
      if (document.visibilityState === 'hidden') {
        sendExitData()
      }
    })
  }
})
