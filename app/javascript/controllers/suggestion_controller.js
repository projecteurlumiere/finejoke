import { Controller } from "@hotwired/stimulus";
import Typed from "typed.js";

// Connects to data-controller="suggestion"
export default class extends Controller {
  static targets = [
    "userInput", "suggestionFormInput",
    "userSubmit",
    "form",
    "response"
  ]

  connect() {
    if (this.hasUserInputTarget) {
      this.placeholder = this.userInputTarget.placeholder
    }
  }

  inputTargetConnected() {
    this.copy()
  }

  responseTargetConnected(el) {
    if (this.typed) this.typed.destroy()
    // this.userInputTarget.disabled = true
    this.userInputTarget.placeholder = this.userInputTarget.value
    this.userInputTarget.value = ""
    this.userSubmitTarget.disabled = true
    const typeSpeed = 5

    this.typed = new Typed(this.userInputTarget, {
      strings: [el.innerText],
      typeSpeed: typeSpeed,
      attr: "placeholder",
      showCursor: false,
      onComplete: () => { 
        this.typed.destroy() 
      },
      onDestroy: () => {
        this.userInputTarget.value = el.innerText
        this.userSubmitTarget.disabled = false
        this.userInputTarget.placeholder = this.placeholder
        // this.userInputTarget.disabled = false
        this.userInputTarget.dispatchEvent(new Event("input"))
        el.remove()
        this.typed = undefined
      }
    });
  }

  copy() {
    if (!this.hasUserInputTarget) return

    this.#cloneInput();
  }

  #cloneInput() {
    this.suggestionFormInputTarget.value = this.userInputTarget.value
  }
}
