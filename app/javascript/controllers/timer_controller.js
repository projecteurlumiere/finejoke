import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="timer"
export default class extends Controller {
  static targets = [ "timings", "circle", "bar", "digits" ]

  connect() {
  }

  timingsTargetConnected() {
    if (this.#setTimings()) {
      this.#setTimer()
    }
  }

  #setTimings() {
    // date in ms
    const newChangeScheduledAt = Math.abs(this.timingsTarget.dataset.changeScheduledAt / 1000)

    switch (isNaN(newChangeScheduledAt) || newChangeScheduledAt) {
      case this.changeScheduledAt:
        return false
        break;
      case true: // which is NaN
      case 0:
      case undefined:
        if (this.timer) clearInterval(this.timer);
        this.#reportTime("")
        return false
        break;
    }

    this.changeScheduledAt = newChangeScheduledAt;
    this.changeDeadline = Math.abs(this.timingsTarget.dataset.changeDeadline / 1000)
    this.interval = this.changeDeadline - this.changeScheduledAt

    return true
  }

  #setTimer() {
    if (this.timer != undefined) { clearInterval(this.timer) }

    this.#timerTick()
    this.timer = setInterval(() => { this.#timerTick() }, 1000)
  }

  #timerTick() {
    // Math abs to new Date returns date in ms
    const timeNow = Math.abs(new Date) / 1000
    const remainingTime = Math.round((this.changeDeadline) - timeNow) // in seconds
    const timeIsUp = remainingTime <= 0 ? true : false

    if (timeIsUp) { 
      this.#reportTime(0)
      clearInterval(this.timer);
    } else {
      this.#reportTime(remainingTime)
    }
  }

  // in seconds
  #reportTime(time) {
    if (this.hasCircleTarget) { this.#updateCircles(time) }
    if (this.hasBarTarget) { this.#updateBars(time) }
    if (this.hasDigitsTarget) { this.#updateDigits(time) }
    console.log(time)
  }

  #updateCircles(time) {
    throw "not implemented"
    // for (var i = this.circleTargets.length - 1; i >= 0; i--) {
    //   this.circleTargets[i]
    // }
  }

  #updateBars(time) {
    for (var i = this.barTargets.length - 1; i >= 0; i--) {
      let bar = this.barTargets[i]

      if (time < 10 && this.interval > 15) {
       bar.classList.add("red")
      } else {
       bar.classList.remove("red")
      }

     bar.style.width = `${bar.parentNode.offsetWidth / this.interval * time}px`
    }
  }

  #updateDigits(time) {
    for (var i = this.digitsTargets.length - 1; i >= 0; i--) {
      if (time < 10 && this.interval > 15) {
        this.digitsTargets[i].classList.add("red")
      } else {
        this.digitsTargets[i].classList.remove("red")
      }

      this.digitsTargets[i].innerText = time;
    }
  }
}
