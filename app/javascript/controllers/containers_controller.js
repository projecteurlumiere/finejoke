import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="containers"
export default class extends Controller {
  static targets = [ "container", "button"]

  show(e) {
    const name = e.target.dataset.containerName;

    console.log(name)
    this.#showContainer(name);
    this.#highlightButton(e.target);
  }

  containerTargetConnected(element) {
    for (var i = this.containerTargets.length - 1; i >= 0; i--) {
      if (!this.containerTargets[i].classList.contains("hidden-when-mobile") && element != this.containerTargets[i]) {
        element.classList.add("hidden-when-mobile");
        break;
      }
    }
  }

  #showContainer(name) {
    for (var i = this.containerTargets.length - 1; i >= 0; i--) {
      const classList = this.containerTargets[i].classList
      console.log(this.containerTargets[i].dataset.containerName)

      if (this.containerTargets[i].dataset.containerName == name) {
        classList.remove("hidden-when-mobile")
      } 
      else {
        classList.add("hidden-when-mobile")
      }
    }
  }

  #highlightButton(node) {
    for (var i = this.buttonTargets.length - 1; i >= 0; i--) {
      const classList = this.buttonTargets[i].classList
      console.log(this.buttonTargets[i])


      if (this.buttonTargets[i] != node) {
        classList.remove("selected")
      } else {
        classList.add("selected")
      }
    }
  }
}
