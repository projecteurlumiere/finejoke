import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="lobby"
export default class extends Controller {
  static targets = [ "leftContainer", "rightContainer", "leftContainerButton", "rightContainerButton" ]

  showLeftContainer(){
    for (var i = this.leftContainerTargets.length - 1; i >= 0; i--) {
      this.leftContainerTargets[i].classList.remove("hidden-when-mobile")
    }

    for (var i = this.rightContainerTargets.length - 1; i >= 0; i--) {
      this.rightContainerTargets[i].classList.add("hidden-when-mobile");
    }

    this.leftContainerButtonTarget.classList.add("selected");
    this.rightContainerButtonTarget.classList.remove("selected");
  }

  showRightContainer(){
    for (var i = this.leftContainerTargets.length - 1; i >= 0; i--) {
      this.leftContainerTargets[i].classList.add("hidden-when-mobile")
    }

    for (var i = this.rightContainerTargets.length - 1; i >= 0; i--) {
      this.rightContainerTargets[i].classList.remove("hidden-when-mobile");
    }

    this.rightContainerButtonTarget.classList.add("selected");
    this.leftContainerButtonTarget.classList.remove("selected");
  }
}
