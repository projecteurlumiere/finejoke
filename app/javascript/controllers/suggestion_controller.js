import { Controller } from "@hotwired/stimulus";
import Typed from "typed.js";

// Connects to data-controller="suggestion"
export default class extends Controller {
  static targets = [
    "userInput", "suggestionFormInput",
    "userSubmit", "suggestionSubmit",
    "form",
    "response"
  ]

  connect() {

  }

  inputTargetConnected() {
    this.copy()
  }

  async responseTargetConnected(el) {
    this.#toggleInput("disable")

    if (this.typed) this.typed.destroy()

    const placeholder = this.injectPlaceholder(this.userInputTarget)
    this.userInputTarget.value = el.innerText

    const typeSpeed = 15

    this.typed = new Typed(placeholder, {
      strings: [el.innerText],
      typeSpeed: typeSpeed,
      showCursor: false,
      loop: false,
      onComplete: () => { 
        this.typed.destroy() 
      },
      onDestroy: () => {
        // this.userInputTarget.value = el.innerText
        this.userInputTarget.style.visibility = ""
        this.userInputTarget.scrollTop = this.userInputTarget.scrollHeight;

        this.#toggleInput("enable")

        // scroll the input once
        this.userInputTarget.dispatchEvent(new Event("input"))
        el.remove()
        placeholder.remove()

        this.typed = undefined
      }
    });
    
    // if something goes wrong it will turn off
    const timeLimit = (typeSpeed * el.innerText.length * 2)
    let timePassed = 0;
    while (this.typed || timePassed > timeLimit) {
      // scrolling bottom
      placeholder.scrollTop = placeholder.scrollHeight

      // to update counter
      this.userInputTarget.dispatchEvent(new CustomEvent("input", {
        detail: {
          length: placeholder.innerHTML.length
        }
      }))

      await new Promise(r => setTimeout(r, typeSpeed));
      timePassed += typeSpeed
    }
  }

  injectPlaceholder(textarea) {
    const placeholder = document.createElement("div")

    placeholder.classList.add("textarea")
    placeholder.dataset.action = "input->symbol-counter#update"
    placeholder.innerHTML = textarea.value

    this.userInputTarget.insertAdjacentElement("afterend", placeholder)
    this.userInputTarget.style.visibility = "hidden"

    return placeholder
  }

  copy() {
    if (!this.hasUserInputTarget) return

    this.#cloneInput();
  }

  #cloneInput() {
    this.suggestionFormInputTarget.value = this.userInputTarget.value
  }

  #toggleInput(directive) {
    [this.userInputTarget, this.userSubmitTarget, this.suggestionSubmitTarget].forEach((el) => {
      el.disabled = directive === "disable" ? true : false
    })
  }
}
