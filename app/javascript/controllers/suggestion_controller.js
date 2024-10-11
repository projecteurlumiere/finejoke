import { Controller } from "@hotwired/stimulus";
import Typed from "typed.js";

// Connects to data-controller="suggestion"
export default class extends Controller {
  static targets = [
    "userInput", "suggestionFormInput",
    "userSubmit", "suggestionSubmit",
    "form",
    "quota",
    "response"
  ]

  disconnect() {
    this.abortTyping();
  }

  copy() {
    if (!this.hasUserInputTarget) return

    this.#cloneInput();
  }

  quotaTargetConnected(el) {
    if (this.typed) return
    this.#checkSuggestionSubmit()
  }

  inputTargetConnected() {
    this.copy()
  }

  responseTargetConnected(el) {
    const suggestion = el.innerText
    el.remove()

    try {
      this.#toggleInput("disable")
      if (this.typed) this.typed.destroy()

      const placeholder = this.#injectPlaceholder(this.userInputTarget)
      this.userInputTarget.value = suggestion

      const typeSpeed = 15 // ms

      this.typed = new Typed(placeholder, {
        strings: [suggestion],
        typeSpeed: typeSpeed,
        showCursor: false,
        loop: false,
        onComplete: () => { 
          this.typed.destroy() 
        },
        onDestroy: () => {
          this.#removePlaceholder(placeholder);
          this.typed = undefined
        }
      });

      this.#scrollPlaceholder(placeholder, typeSpeed, suggestion)
    } catch (error) {
      try {
        if (this.typed) {
          this.typed.destroy()
        }
      } catch (error) {
        console.log(error)
        this.typed = undefined
      }

      if (placeholder) { this.#removePlaceholder(placeholder); }
    } finally {
      this.#toggleInput("enable")
      this.userInputTarget.value = suggestion;
    }
  }

  abortTyping() {
    if (this.typed) this.typed.destroy()
  }

  #toggleInput(directive) {
    const action = directive === "disable" ? true : false;
    const inputs = [this.userInputTarget, this.userSubmitTarget, this.suggestionSubmitTarget]

    inputs.forEach((el) => {
      if (action === false && el === this.suggestionSubmitTarget) {
        this.#checkSuggestionSubmit()
      } else {
        el.disabled = action
      }
    })
  }

  #checkSuggestionSubmit() {
    if (this.quotaTarget.innerHTML.trim() === "0") {
      this.suggestionSubmitTarget.disabled = true
    } else {
      this.suggestionSubmitTarget.disabled = false
    }
  }

  #cloneInput() {
    this.suggestionFormInputTarget.value = this.userInputTarget.value
  }

  #injectPlaceholder(textarea) {
    const placeholder = document.createElement("div")

    placeholder.classList.add("textarea")
    placeholder.dataset.action = "input->symbol-counter#update click->suggestion#abortTyping"
    placeholder.innerHTML = textarea.value

    this.userInputTarget.insertAdjacentElement("afterend", placeholder)
    this.userInputTarget.style.visibility = "hidden"

    return placeholder
  }

  #removePlaceholder(placeholder) {
    this.userInputTarget.style.visibility = ""
    this.userInputTarget.scrollTop = this.userInputTarget.scrollHeight;
    this.#toggleInput("enable")
    // scroll the input once
    this.userInputTarget.dispatchEvent(new Event("input"))
    placeholder.remove()
  }

  #scrollPlaceholder(placeholder, typeSpeed, suggestion) {
    // if something goes wrong it will turn off
    const timeLimit = typeSpeed * suggestion.length * 2
    let timePassed = 0;

    // timeout is neccesary so that it doesn't start count too early
    // when placeholder has the entire content in it, 
    // i.e. before typed is initialized
    setTimeout(async () => {
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
    }, typeSpeed * 2)
  }
}
