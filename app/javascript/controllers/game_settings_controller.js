import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="game-settings"
export default class extends Controller {
  showRules(e) {
    if (!e.detail.success) return
    
    const button = document.querySelector(".button[data-container-name=round]");
    // if buitton is invisible
    if (button.offsetHeight === 0) return

    button.click();
  }
}
