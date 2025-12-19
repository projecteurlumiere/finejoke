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

  stopForceShowingRules() {
    document.querySelector("#current-round > div").dataset.forceShowingRules = ""
  }

  checkResponse(e) {
    if (e.detail.newStream.target != "current-round") return

    const presentRoundAttr = document.querySelector("#current-round #round-state");

    const stream = e.detail.newStream.querySelector("template").content;
    const incomingRoundAttr = stream.querySelector("#current-round #round-state");

    if (presentRoundAttr.dataset.forceShowingRules === "true") {
      document.querySelector(".action button").classList.add("blinking")
      e.preventDefault()
      return
    }

    if (this.#attributesEqual(presentRoundAttr, incomingRoundAttr)) {
      e.preventDefault();
      console.log("Received the same round stream");
      return
    }

    console.log("Replaced current-round with new stream");
  }

  #attributesEqual(presentRoundAttr, incomingRoundAttr) {
    const ds1 = {...presentRoundAttr.dataset};
    const ds2 = {...incomingRoundAttr.dataset};

    const keys1 = Object.keys(ds1);
    const keys2 = Object.keys(ds2);

    if (keys1.length !== keys2.length) return false;

    for (const key of keys1) {
      if (ds1[key] !== ds2[key]) return false;
    }

    return true;
  }
}
