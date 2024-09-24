import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["long", "short"]

  toggleView() {
    if (!this.hasShortTarget ||
        (this.#elementContainsSelection(this.longTarget) || 
        this.#elementContainsSelection(this.shortTarget))) {
      return
    }

    this.longTarget.classList.toggle("hidden")
    this.shortTarget.classList.toggle("hidden")
  }


  #elementContainsSelection(el) {
    const sel = window.getSelection();

    if (sel.toString() && sel.rangeCount > 0) {
      for (let i = 0; i < sel.rangeCount; ++i) {
        if (!el.contains(sel.getRangeAt(i).commonAncestorContainer)) {
          return false;
        }
      }
      return true;
    }
    return false;
  }
}