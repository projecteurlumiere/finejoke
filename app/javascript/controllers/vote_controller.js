import { Controller } from "@hotwired/stimulus"
  
// Connects to data-controller="vote"
export default class extends Controller {
  static targets = [ "jokes", "joke", "previous", "next", "submit" ]

  connect() {
    // this.#setSubmitLink();
  }

  next() {
    this.#move("next");
  }

  previous() {
    this.#move("previous");
  }

  // container
  jokesTargetConnected() {
    this.#restrictNextMove(0);
  } 

  #move(action) {
    let current = this.#getCurrentJoke();

    let new_current = {
      i: (action === "next" ? current.i + 1 : current.i - 1),
      node: undefined
    } 

    if (new_current.i >= this.jokeTargets.length || new_current.i < 0) return
    this.#restrictNextMove(new_current.i)

    new_current.node = this.jokeTargets[new_current.i]

    current.node.classList.add("hidden");
    new_current.node.classList.remove("hidden");

    this.#setSubmitLink(new_current.node);
  }

  #restrictNextMove(i) {
    if (i + 1 >= this.jokeTargets.length) {
      this.#disable(this.nextTarget);
    }
    else {
      this.#enable(this.nextTarget);
    }

    if (i - 1 < 0) {
      this.#disable(this.previousTarget);
    }
    else {
      this.#enable(this.previousTarget);
    }
  }

  #setSubmitLink(joke = undefined) {
    if (!this.hasInputTarget) return
      
    joke = joke === undefined ? this.#getCurrentJoke().node : joke

    this.submitTarget.action = joke.dataset.votePath
  }

  // returns object with joke and position
  #getCurrentJoke() {
    for (var i = this.jokeTargets.length - 1; i >= 0; i--) {
      if (!this.jokeTargets[i].classList.contains("hidden")) {
        return { 
          i: i, 
          node: this.jokeTargets[i]
        } 
      }
    }
  }

  #enable(button) {
    button.classList.remove("disabled");
  }

  #disable(button) {
    button.classList.add("disabled");
  }
}
