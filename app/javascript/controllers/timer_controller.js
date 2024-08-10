import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="timer"
export default class extends Controller {
  static targets = [ "timings", "circle", "border", "digits" ]

  connect() {
  }

  timingsTargetConnected() {
    if (this.#setTimings()) {
      this.#setTimer()
    }
  }

  #setTimings() {
    // date in ms
    const newChangeScheduledAt = this.timingsTarget.dataset.changeScheduledAt
    if (newChangeScheduledAt === this.changeScheduledAt) { return false }

    this.changeScheduledAt = newChangeScheduledAt;
    this.changeDeadline = this.timingsTarget.dataset.changeDeadline

    return true
  }

  #setTimer() {
    if (this.timer != undefined) { clearInterval(this.timer) }

    this.#timerTick()
    this.timer = setInterval(() => { this.#timerTick() }, 1000)
  }

  #timerTick() {
    // Math abs to new Date returns date in ms
    const remainingTime = Math.round((Math.abs(this.changeDeadline) - Math.abs(new Date)) / 1000) // in seconds
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
    if (this.hasBorderTarget) { this.#updateBorders(time) }
    if (this.hasDigitsTarget) { this.#updateDigits(time) }
    console.log(time)
  }

  #updateCircles(time) {
    for (var i = this.circleTargets.length - 1; i >= 0; i--) {
      this.circleTargets[i]
    }
  }

  #updateBorders(time) {
    for (var i = this.BorderTargets.length - 1; i >= 0; i--) {
      this.BorderTargets[i]
    }
  }

  #updateDigits(time) {
    for (var i = this.digitsTargets.length - 1; i >= 0; i--) {
      this.digitsTargets[i].innerText = time;
    }
  }
}
