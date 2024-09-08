import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["long", "short"]

  toggleView() {
    if (!this.hasShortTarget) return

    this.longTarget.classList.toggle("hidden")
    this.shortTarget.classList.toggle("hidden")
  }
}