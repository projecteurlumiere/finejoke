import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="flash"
export default class extends Controller {
  hide(e) {
    e.target.style.visibility = "hidden";
  }
}
