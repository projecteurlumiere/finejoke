import { Controller } from "@hotwired/stimulus"
import Swipe from "swipejs";
  
// Connects to data-controller="vote"
export default class extends Controller {
  static targets = [ 
    "state",
    "jokes", "joke", "previous", "next", "action", "counter",
    "task", "description", // counting visible area
    "buttons" // necessary for both controller & counting
    ]

  next() {
    this.swipe.next()
  }

  previous() {
    this.swipe.prev()
  }

  goToJoke(e) {
    if (e.target.dataset.index) this.swipe.slide(e.target.dataset.index)
  }

  // container
  jokesTargetConnected() {
    // for (var i = this.jokeTargets.length - 1; i >= 0; i--) {
    //   this.jokeTargets[i].classList.remove("hidden");
    // }

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
    this.buttonsTarget.style.visibility = "visible"
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
    this.element.style.setProperty("--visible-height-for-joke", `${visibleHeight}px`)

    setTimeout(() => {
      for (var i = this.jokeTargets.length - 1; i >= 0; i--) {
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
    }, 200)
    
  }

  changeAction(e) {
    if (e.detail.success) {
      let button = this.actionTarget.querySelector("button[type=submit]")
      button.classList.add("disabled")
      button.innerText = this.actionTarget.dataset.disabledText
      this.stateTarget.dataset.userVoted = "true"
    }
  }

  #setJoke(index, elem) {
    this.#restrictNextMove(index);
    this.#setActionLink(elem);
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

  #setActionLink(element) {
    if (!this.hasActionTarget) return

    this.actionTarget.action = element.dataset.votePath
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

  #countVisibleAreaForJoke() {
    return this.taskTarget.offsetHeight -
      this.descriptionTarget.offsetHeight -
      window.getComputedStyle(this.descriptionTarget).marginBottom.slice(0, -3) - 
      this.buttonsTarget.offsetHeight -
      window.getComputedStyle(this.buttonsTarget).paddingTop.slice(0, -3) - 
      window.getComputedStyle(this.buttonsTarget).paddingBottom.slice(0, -3)
  }
}

