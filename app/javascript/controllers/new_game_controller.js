import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="new-game"
export default class extends Controller {
  static targets = ["name", "viewable", "viewersVote"]

  connect() {
    this.toggleViewable()
  }

  validate(e) {
    this.invalid = false

    // this.#validateName();

    if (this.invalid) { e.preventDefault(); }
  }
 
  toggleViewable(e = undefined) {
    return // because viewableTarget is absent. see new game form partial: games/_form
    
    if (!e) {
      if (!this.viewableTarget.checked && this.viewersVoteTarget.checked) {
        this.viewableTarget.checked = true
        this.viewersVoteTarget.checked = true
      }
    } 
    else if (e.currentTarget === this.viewersVoteTarget && this.viewersVoteTarget.checked) {
      this.viewableTarget.checked = true
    } 
    else if (e.currentTarget == this.viewableTarget && !this.viewableTarget.checked) {
      this.viewersVoteTarget.checked = false
    }
  }

  #validateName() {
    // if (this.nameTarget.value === "") {
    //   this.nameTarget.setCustomValidity("У игры должно быть имя")
    //   this.invalid = true
    // }
  }
}