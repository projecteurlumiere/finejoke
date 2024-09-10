import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="word-counter"
export default class extends Controller {
  static targets = [ "counter" ]

  counterTargetConnected(node) {
    this.#setCount(this.#getInput(node), node)
  }

  update(event) {
    const input = event.target
    this.#setCount(input, this.#getCounter(input))
  }

  #getInput(counterNode) {
    return document.getElementById(counterNode.dataset.input)
  }

  #getCounter(inputNode) {
    const id = inputNode.id

    for (var i = this.counterTargets.length - 1; i >= 0; i--) {
      if (this.counterTargets[i].dataset.input === id) {
        return this.counterTargets[i]
      }
    }
  }

  #setCount(input, counter) {
    counter.innerHTML = input.maxLength - input.value.length
  }
}
