import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="word-counter"
export default class extends Controller {
  static targets = [ "counter" ]

  counterTargetConnected(node) {
    this.#setCount(this.#getInput(node), node)
  }

  update(event) {
    const input = event.target
    const length = event.detail && event.detail.length ? event.detail.length : undefined

    this.#setCount(input, this.#getCounter(input), length)
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

  #setCount(input, counter, length = undefined) {
    length = length || input.value.length

    counter.innerHTML = input.maxLength - length
  }
}
