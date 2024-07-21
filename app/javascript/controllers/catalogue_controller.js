import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="catalogue"
export default class extends Controller {
  static targets = [ "connect", "view", "entry" ]

  select(e) {
    if (e.target.classList.contains("select")) { this.#deselect(e); return }
    this.#deselectTheRest();

    this.connectTarget.href = e.target.dataset.joinPath;
    this.viewTarget.href = e.target.dataset.viewPath;
    e.target.classList.add("select")

    this.#removeDisabled();
  }

  #deselect(e) {
    this.#addDisabled();
    e.target.classList.remove("select")

    this.connectTarget.href = "";
    this.viewTarget.href = "";
  }

  #deselectTheRest() {
    for (var i = this.entryTargets.length - 1; i >= 0; i--) {
      this.entryTargets[i].classList.remove("select")
    }
  }

  #removeDisabled() {
    if (this.connectTarget.href === "" || this.viewTarget.href === "") { 
      this.#addDisabled;
      return 
    }

    this.connectTarget.classList.remove("disabled");
    this.viewTarget.classList.remove("disabled");
  }

  #addDisabled(){
    this.connectTarget.classList.add("disabled");
    this.viewTarget.classList.add("disabled");
  }
}
