import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="scroll"
export default class extends Controller {
  scrollToTop(e) {
   document.querySelector("header").scrollIntoView({ behavior: "smooth", block: "start" });
  }
}
