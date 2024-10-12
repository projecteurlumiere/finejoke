import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="catalogue"
export default class extends Controller {
  static targets = [ "connect", "view", "entry", "form" ]

  connect() {
    if (this.hasFormTarget) {
      this.submit();
    }
  }

  // for forms
  submit() {
    this.formTarget.requestSubmit();
  }

  // the following select-related things work in the lobby game catalogue only

  entryTargetDisconnected(el) {
    if (el.classList.contains("select")) {
      this.#deselect(el);
    }
  } 

  select(e) {
    const el = e.currentTarget

    if (el.classList.contains("select")) { this.#deselect(el); return }
    this.#deselectTheRest();

    this.connectTarget.parentNode.action = el.dataset.joinPath;
    this.viewTarget.href = el.dataset.viewPath;
    el.classList.add("select")

    this.#removeDisabled();
  }

  #deselect(el) {
    this.#addDisabled();
    el.classList.remove("select")

    this.connectTarget.parentNode.action = "";
    this.viewTarget.href = "";
  }

  #deselectTheRest() {
    for (var i = this.entryTargets.length - 1; i >= 0; i--) {
      this.entryTargets[i].classList.remove("select")
    }
  }

  #removeDisabled() {
    this.connectTarget.disabled = false;
    this.viewTarget.classList.remove("disabled");
  }

  #addDisabled(){
    this.connectTarget.disabled = true;
    this.viewTarget.classList.add("disabled");
  }
}
