// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "channels"
import "controllers"

Turbo.StreamActions.redirect = function() {
  Turbo.visit(this.target, { action: "replace" })
}

Turbo.StreamActions.fetch = function() {
  fetch(this.target, {
      headers: {
        Accept: "text/vnd.turbo-stream.html",
      },
    }).then(r => r.text())
      .then(html => Turbo.renderStreamMessage(html))
}