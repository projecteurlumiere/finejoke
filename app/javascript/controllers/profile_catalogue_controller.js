import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="profile-catalogue"
export default class extends Controller {
  static targets = [ "form" ]

  connect() {
    this.submit();
  }

  submit() {
    this.formTarget.requestSubmit();
  }
}
