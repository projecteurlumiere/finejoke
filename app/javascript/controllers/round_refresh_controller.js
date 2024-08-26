import { Controller } from "@hotwired/stimulus"
import "@hotwired/turbo-rails"

// Connects to data-controller="round"
export default class extends Controller {
  static values = { 
    url: String 
  }

  fetch() {
    if (!document.hidden) {
      fetch(this.urlValue, {
          headers: {
            Accept: "text/vnd.turbo-stream.html",
          },
        }).then(r => r.text())
          .then(html => Turbo.renderStreamMessage(html))
    }
  }

  checkResponse(e) {
    if (e.detail.newStream.target != "current-round") return

    const presentString = document.querySelector("#current-round > div").outerHTML
    
    const stream = e.detail.newStream.querySelector("template").content
    const incomingString = stream.querySelector("#current-round > div").outerHTML

    const presentHash = this.#digest(presentString.replace(/\n/g, ''))
    const incomingHash = this.#digest(incomingString.replace(/\n/g, ''))

    if (presentHash === incomingHash) {
      e.preventDefault()
    }
  }

  // // this is async digest using browser's in-built crypto api  
  // async #digest(string) {
  //   const msgUint8 = new TextEncoder().encode(string); // encode as (utf-8) Uint8Array
  //   const hashBuffer = await window.crypto.subtle.digest("SHA-256", msgUint8); // hash the message
  //   const hashArray = Array.from(new Uint8Array(hashBuffer)); // convert buffer to byte array
  //   const hashHex = hashArray
  //     .map((b) => b.toString(16).padStart(2, "0"))
  //     .join(""); // convert bytes to hex string
    
  //   return hashHex
  // }

  // this is some (more primitive) java implementation without async that ruin
  // prevent default behaviour
  #digest(string) {
    let hash = 0;
    for (let i = 0, len = string.length; i < len; i++) {
        let chr = string.charCodeAt(i);
        hash = (hash << 5) - hash + chr;
        hash |= 0; // Convert to 32bit integer
    }
    return hash;
  }
}
