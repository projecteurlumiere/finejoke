import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="chat"
export default class extends Controller {
  static targets = [ "form" ]

  resetForm(e) {
    if (e.target != this.formTarget) return
    if (e.detail.success) this.formTarget.reset();
  }
}
