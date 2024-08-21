import { Controller } from "@hotwired/stimulus"
import Swipe from "swipejs";
  
// Connects to data-controller="vote"
export default class extends Controller {
  static targets = [ "jokes", "joke", "previous", "next", "submit", "counter" ]

  next() {
    this.swipe.next()
    // this.#move("next");
  }

  previous() {
    this.swipe.prev()
    // this.#move("previous");
  }

  goToJoke(e) {
    const divs = this.counterTarget.querySelectorAll("div");
    for (var i = divs.length - 1; i >= 0; i--) {
      if (e.target === divs[i]) {
        this.swipe.slide(i)
      }
    }
  }

  // container
  jokesTargetConnected() {
    for (var i = this.jokeTargets.length - 1; i >= 0; i--) {
      this.jokeTargets[i].classList.remove("hidden")
    }

    this.swipe = new Swipe(document.getElementById("swipe"), 
      { 
        ignore: ".buttons",
        continuous: false,
        callback: (index, elem, dir) => { 
          this.#setJoke(index, elem)
        }
      }
    );

    this.#setJoke(0, this.jokeTargets[0]);
  }

  jokesTargetDisconnected() {
    this.swipe.kill()
  }

  #setJoke(index, elem) {
    this.#restrictNextMove(index);
    this.#setSubmitLink(elem);
    this.#highlightCounter(index);
  }

  #restrictNextMove(i) {
    if (i + 1 >= this.swipe.getNumSlides()) {
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

  #setSubmitLink(element) {
    if (!this.hasSubmitTarget) return

    this.submitTarget.action = element.dataset.votePath
  }

  #highlightCounter(index) {
    const divs = this.counterTarget.querySelectorAll("div");

    for (var i = divs.length - 1; i >= 0; i--) {
      if (i === index) { 
        divs[i].classList.add("selected")
      } 
      else {
        divs[i].classList.remove("selected")
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
