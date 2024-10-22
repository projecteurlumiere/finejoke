import { Controller } from "@hotwired/stimulus"

// connects to data-controller="sound"
// 1. toggles sound in sessionStorage
// 2. waits for Soundable target to connect and plays the relevant sound
// soundable target values:
//   soundName - used to determine url of the sound (see GamesHelper)
//   soundUniqIdentifier - used to determine if sound has already been played via sessionStorage in case user receives a page update
// if no unique ID provided, it just removes data-sound-target="soundable" from the element
// (useful for chat-messages and their history)
export default class extends Controller {
  static targets = ["soundable", "control"]
  static values = {
    bubbleUrl: String,
    turnUrl: String
  }

  connect() {
    this.#clearSoundableHistory()
  }

  disconnect() {
    this.#clearSoundableHistory()
  }

  toggle() {
    if (sessionStorage.getItem("sound_disabled")) {
      sessionStorage.removeItem("sound_disabled")
      this.controlTarget.classList.remove("disabled")
    } else {
      sessionStorage.setItem("sound_disabled", true)
      this.controlTarget.classList.add("disabled")
    }
  }

  controlTargetConnected() {
    if (this.#soundEnabled()) {
      this.controlTarget.classList.remove("disabled")
    } else {
      this.controlTarget.classList.add("disabled")
    }

    this.controlTarget.classList.remove("hidden");
  }

  soundableTargetConnected(el) {
    let id;
    
    if (el.dataset.soundUniqIdentifier) {
      id = `sound_for_${el.dataset.soundUniqIdentifier}_played_at`
    } else {
      el.removeAttribute("data-sound-target");
    }

    if (this.#soundEnabled() && (!id || !sessionStorage.getItem(id))) {
      new Audio(this[`${el.dataset.soundName}UrlValue`]).play()
    }

    if (id) sessionStorage.setItem(id, new Date)
  }

  #clearSoundableHistory(){
    const storePeriod = 600_000 // ten minutes in ms

    for (var i = 0; i < sessionStorage.length; i++){
      const key = sessionStorage.key(i)
      if (!key.startsWith("sound_for_")) continue

      const interval = new Date - new Date(sessionStorage.getItem(key)) 
      if (interval > storePeriod) sessionStorage.removeItem(key) 
    }
  }

  #soundEnabled() {
    return !this.#soundDisabled()
  }

  #soundDisabled() {
    return sessionStorage.getItem("sound_disabled");
  }
}
