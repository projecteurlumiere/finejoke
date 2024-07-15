import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="catalogue"
export default class extends Controller {
  static targets = [ "connect", "view" ]

  select(e) {
    if (e.target.classList.contains("select")) { this.#deselect(e); return }

    this.connectTarget.href = e.target.dataset.joinPath;
    this.viewTarget.href = e.target.dataset.viewPath;
    this.#removeDisabled();

    e.target.classList.add("select")
  }

  #deselect(e) {
    this.#addDisabled();

    this.connectTarget.href = "";
    this.viewTarget.href = "";

    e.target.classList.remove("select")
  }

  #removeDisabled() {
    this.connectTarget.classList.remove("disabled");
    this.viewTarget.classList.remove("disabled");
  }

  #addDisabled(){
    this.connectTarget.classList.add("disabled");
    this.viewTarget.classList.add("disabled");
  }
}
