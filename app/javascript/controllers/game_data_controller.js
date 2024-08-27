import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="game-list"
export default class extends Controller {
  static values = {
    id: String,
    host: Boolean
  }

  static targets = [ "user" ]

  connect(){
    this.timeouts = {}
  }

  showSettings(e) {
    let node = e.currentTarget;
    const id = node.id
    const settingsNode = node.querySelector(".settings")
    if (window.getComputedStyle(settingsNode).display === "none") {
      e.preventDefault()
    } 

    if (this.timeouts[id]) {
      clearTimeout(this.timeouts[id])
    } else {
      node.classList.add("clicked");
    }

    this.timeouts[id] = setTimeout(() => {
      node.classList.remove("clicked");
      delete this.timeouts[id]
    }, "2000");
  }

  userTargetConnected(node) {
    if (node.dataset.id == this.idValue) {
      this.hostValue = node.dataset.host
    } else if (this.hostValue == true) {
      this.#hostButtons("show", node)
    }     
  }

  userTargetDisconnected(node) {
    if (node.dataset.id == this.idValue) this.hostValue = false 
  }

  #hostValueChanged() {
    const directive = this.hostValue === true ? "show" : "false"

    for (var i = this.userTargets.length - 1; i >= 0; i--) {
      
      this.#hostButtons(directive, this.userTargets[i])
    }
  }

  #hostButtons(directive, node) { 
    const hiddenNodes = node.querySelectorAll(".settings .hidden");

    for (var i = hiddenNodes.length - 1; i >= 0; i--) {
      const list = hiddenNodes[i].classList

      if (hiddenNodes[i].dataset.id == this.idValue) {
        list.add("hidden")
        return
      }

      if (directive === "hide") { list.add("hidden") } 
      if (directive === "show") { list.remove("hidden") }
    }
  }
}
