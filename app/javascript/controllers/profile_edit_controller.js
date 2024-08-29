import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="profile-edit"
export default class extends Controller {
  static targets = [ "editForm", "deleteForm", "passwordField", "passwordHiddenField" ]

  connect() {

  }

  copyPassword() {
    this.passwordHiddenFieldTarget.value = this.passwordFieldTarget.value;
  }

  submitDeleteForm(e) {
    if (this.passwordFieldTarget.checkValidity()) {
      this.copyPassword();
      this.deleteFormTarget.requestSubmit();
    } else {
      this.passwordFieldTarget.focus()
      e.preventDefault();
    }
  }

}
