import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="locale"
export default class extends Controller {
  static targets = [ "form" ]

  submit(e) {
    // removing anchors and params
    this.element.querySelector("#current_page").value = 
      window.location.href.split(/[?#]/)[0];

    // either controller is attached to the form or the form is a target
    if (this.hasFormTarget) {
      this.formTarget.querySelector("#locale").value = e.target.value
      this.formTarget.requestSubmit()
    } else {
      this.element.requestSubmit()
    }
  }
}
