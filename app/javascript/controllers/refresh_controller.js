import { Controller } from "@hotwired/stimulus"
import "@hotwired/turbo-rails"

// Connects to data-controller="round"
export default class extends Controller {
  static values = { 
    url: String 
  }

  fetch() {
    if (!document.hidden) {
      fetch(this.urlValue, {
          headers: {
            Accept: "text/vnd.turbo-stream.html",
          },
        }).then(r => r.text())
          .then(html => Turbo.renderStreamMessage(html))
    }
  }
}
