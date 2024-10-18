import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="user-status"
export default class extends Controller {
  static targets = [ "unupdatable" ]

  // halts entire stream if unupdatable target is present
  checkResponse(e) {
    const stream = e.detail.newStream.querySelector("template").content;
    const incomingStatus = stream.querySelector("#user-status");

    if (incomingStatus && this.hasUnupdatableTarget) {
      e.preventDefault()
    }
  }
}
