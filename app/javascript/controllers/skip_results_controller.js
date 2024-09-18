import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="skip-results"
export default class extends Controller {

  // disables "I want to skip results" button on successful response
  disable(e) {
    if (e.detail.success) {
      let button = this.element.querySelector("button[type=submit]")
      button.classList.add("disabled")
      button.innerText = this.element.dataset.disabledText

      let roundState = document.getElementById("round-state")
      roundState.dataset.userWantsToSkipResults = "true"
    }
  }
}
