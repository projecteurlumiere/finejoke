import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="new-game"
export default class extends Controller {
  static targets = [ "name" ]

  validate(e) {
    this.invalid = false

    // this.#validateName();

    if (this.invalid) { e.preventDefault(); }
  }

  #validateName() {
    // if (this.nameTarget.value === "") {
    //   this.nameTarget.setCustomValidity("У игры должно быть имя")
    //   this.invalid = true
    // }
  }
}
