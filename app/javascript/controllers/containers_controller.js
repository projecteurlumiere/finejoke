import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="containers"
export default class extends Controller {
  static targets = [ "container", "button"]

  show(e) {
    this.#showByName(e.currentTarget.dataset.containerName);
  }

  #showByName(name) {
    this.#showContainer(name);
    this.#highlightButton(name);
  }

  containerTargetConnected(element) {
    const name = element.dataset.containerName

    for (var i = this.containerTargets.length - 1; i >= 0; i--) {
      if (!this.containerTargets[i].classList.contains("hidden-when-mobile") && this.containerTargets[i] != element) {
        this.#showByName(this.containerTargets[i].dataset.containerName)
        return
      }
    }

    this.#showByName(name)
  }


  #showContainer(name) {
    for (var i = this.containerTargets.length - 1; i >= 0; i--) {
      const classList = this.containerTargets[i].classList

      if (this.containerTargets[i].dataset.containerName == name) {
        classList.remove("hidden-when-mobile")
      } 
      else {
        classList.add("hidden-when-mobile")
      }
    }
  }

  #highlightButton(name) {
    for (var i = this.buttonTargets.length - 1; i >= 0; i--) {
      const classList = this.buttonTargets[i].classList

      if (this.buttonTargets[i].dataset.containerName != name) {
        classList.remove("selected")
      } else {
        classList.add("selected")
      }
    }
  }
}
