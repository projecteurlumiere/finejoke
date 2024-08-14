import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="flash"
export default class extends Controller {
  hide(e) {
    this.element.style.display = "none";
  }
}
