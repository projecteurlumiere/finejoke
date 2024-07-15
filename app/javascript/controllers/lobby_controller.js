import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="lobby"
export default class extends Controller {
  static targets = [ "catalogue", "form", "roomsButton", "formButton" ]


  showCatalogue() {
    for (var i = this.catalogueTargets.length - 1; i >= 0; i--) {
      this.catalogueTargets[i].classList.remove("hidden-when-mobile")
    }

    for (var i = this.formTargets.length - 1; i >= 0; i--) {
      this.formTargets[i].classList.add("hidden-when-mobile");
    }

    this.roomsButtonTarget.classList.add("selected");
    this.formButtonTarget.classList.remove("selected");

  }

  showForm() {
    for (var i = this.catalogueTargets.length - 1; i >= 0; i--) {
      this.catalogueTargets[i].classList.add("hidden-when-mobile")
    }

    for (var i = this.formTargets.length - 1; i >= 0; i--) {
      this.formTargets[i].classList.remove("hidden-when-mobile");
    }

    this.formButtonTarget.classList.add("selected");
    this.roomsButtonTarget.classList.remove("selected");
  }
}
