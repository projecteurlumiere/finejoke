import { Controller } from "@hotwired/stimulus"
import Swipe from "swipejs";
  
// Connects to data-controller="vote"
export default class extends Controller {
  static targets = [ 
    "state",
    "jokes", "joke", "previous", "next", "action", "counter",
    "task", "description", "setup", "buttons",
    "swipeWrap"
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
    this.swipe = new Swipe(document.getElementById("swipe"), 
      { 
        ignore: ".buttons",
        continuous: false,
        callback: (index, elem, dir) => { 
          this.#setJoke(index, elem)
        }
      }
    );

    if (!this.observer) this.#setObserver()
    this.observer.observe(this.jokesTarget)

    this.#setJoke(0, this.jokeTargets[0]);
    this.buttonsTarget.style.visibility = "visible"
    this.fitJoke();
  }

  jokesTargetDisconnected() {
    this.swipe.kill()
    this.observer.unobserve(this.jokesTarget)
  }

  fitJoke() {
    if (!this.hasJokesTarget || 
        window.getComputedStyle(this.element).display === "none") return

    const jokeHeight = this.jokeTargets[this.swipe.getPos()].offsetHeight
    const visibleArea = this.#countVisibleAreaForJoke();

    const height = jokeHeight > visibleArea ? jokeHeight : visibleArea

    this.swipe.setup()
    this.swipeWrapTarget.style.height = `${height}px`
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

    this.fitJoke();
    elem.classList.add("selected");

    for (var i = this.jokeTargets.length - 1; i >= 0; i--) {
      if (this.jokeTargets[i] != elem) {
        this.jokeTargets[i].classList.remove("selected")
      }
    }

    this.taskTarget.scrollTo(0, 0);
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
      window.getComputedStyle(this.descriptionTarget).marginTop.slice(0, -3) -
      window.getComputedStyle(this.descriptionTarget).marginBottom.slice(0, -3) -
      this.setupTarget.offsetHeight -
      window.getComputedStyle(this.setupTarget).marginTop.slice(0, -3) -
      window.getComputedStyle(this.setupTarget).marginBottom.slice(0, -3) -
      this.buttonsTarget.offsetHeight - 
      this.buttonsTarget.offsetHeight
      // why two times? I don't know - perhaps, because it's sticky
  }

  #setObserver() {
    this.observer = new IntersectionObserver((elements) => {  
      for (var i = elements.length - 1; i >= 0; i--) {
        if (elements[i].isIntersecting) {
          elements[i].target.dispatchEvent(new Event("jokesvisible", {bubbles: true}))
        }
      }
    }, {
      threshold: 0.1
    })
  }
}

