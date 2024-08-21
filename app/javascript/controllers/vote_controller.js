import { Controller } from "@hotwired/stimulus"
import Swipe from "swipejs";
  
// Connects to data-controller="vote"
export default class extends Controller {
  static targets = [ "jokes", "joke", "previous", "next", "submit" ]

  next() {
    this.swipe.next()
    // this.#move("next");
  }

  previous() {
    this.swipe.prev()
    // this.#move("previous");
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
          this.#restrictNextMove(index);
          this.#setSubmitLink(elem); 
        }
      }
    );

    this.#restrictNextMove(0);
  }

  jokesTargetDisconnected() {
    this.swipe.kill()
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

  #enable(button) {
    button.classList.remove("disabled");
  }

  #disable(button) {
    button.classList.add("disabled");
  }
}
