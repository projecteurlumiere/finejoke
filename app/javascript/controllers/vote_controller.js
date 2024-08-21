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
      this.jokeTargets[i].classList.remove("hidden");
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

    this.countJokeFitness();
  }

  jokesTargetDisconnected() {
    this.swipe.kill()
  }

  countJokeFitness() {
    if (!this.hasJokesTarget) return

    for (var i = this.jokeTargets.length - 1; i >= 0; i--) {
      this.jokeTargets[i].style.visibility = "hidden"
      this.jokeTargets[i].classList.remove("fit")
    }

    const visibleHeight = this.#countVisibleAreaForJoke();
    document.querySelector(":root").style.setProperty("--joke-visible-height", `${visibleHeight}px`)

    setTimeout(() => {
      for (var i = this.jokeTargets.length - 1; i >= 0; i--) {
        console.log(this.jokeTargets[i].offsetHeight, visibleHeight)
        if (this.jokeTargets[i].offsetHeight <= visibleHeight) {
          this.jokeTargets[i].classList.add("fit")
        } else {
          this.jokeTargets[i].classList.remove("fit")
        }
        
        document.querySelector(".swipe-wrap").style.height = `${this.jokeTargets[this.swipe.getPos()].offsetHeight}px`
      }
    }, 100)

    setTimeout(() => { 
      for (var i = this.jokeTargets.length - 1; i >= 0; i--) {
        this.jokeTargets[i].style.visibility = "unset"
      }
    }, 300)
    
  }

  #setJoke(index, elem) {
    this.#restrictNextMove(index);
    this.#setSubmitLink(elem);
    this.#highlightCounter(index);
    const visibleHeight = this.#countVisibleAreaForJoke();
    if (elem.offsetHeight <= visibleHeight) {
      elem.classList.add("fit")
    } else {
      elem.classList.remove("fit")
    }

    document.querySelector(".swipe-wrap").style.height = `${elem.offsetHeight}px`
    elem.classList.add("selected");
    for (var i = this.jokeTargets.length - 1; i >= 0; i--) {
      if (this.jokeTargets[i] != elem) {
        this.jokeTargets[i].classList.remove("selected")
      }
    }
    document.querySelector(".task").scrollTo(0, 0);
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

  #countVisibleAreaForJoke(){
    return document.querySelector(".task").offsetHeight - 
      document.querySelector(".description").offsetHeight - 
      window.getComputedStyle(document.querySelector(".description")).marginBottom.slice(0, -3) -
      document.querySelector("#current-round .buttons").offsetHeight - 
      window.getComputedStyle(document.querySelector("#current-round .buttons")).paddingTop.slice(0, -3) - 
      window.getComputedStyle(document.querySelector("#current-round .buttons")).paddingBottom.slice(0, -3);
  }
}
