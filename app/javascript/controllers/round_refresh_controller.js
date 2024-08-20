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

  checkResponse(e) {
    const target = e.detail.newStream.target
    if (target != "current-round") return

    try {
      const presentTimestamp = document.getElementById(target).querySelector("#current-round > div").dataset.changeScheduledAt
      const incomingTimestamp = e.detail.newStream.querySelector("template").content.querySelector("#current-round > div").dataset.changeScheduledAt
      if (presentTimestamp === incomingTimestamp) {
        e.preventDefault()
      }
    } catch (e) {
      return
    }
  }
}
