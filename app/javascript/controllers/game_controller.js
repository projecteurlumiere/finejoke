import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  initialize() {
    console.log("initialized")
    this.channel = consumer.subscriptions.create({ 
        channel: "GameChannel",
        game: this.element.dataset.id
      }, {
        connected() {
          // Called when the subscription is ready for use on the server
        },

        disconnected() {
          // Called when the subscription has been terminated by the server
        },

        received(data) {
          console.log("received: " + data)
        }
    });
  }

  connect() {
    console.log("i am connecting");
  }

  disconnect() {
    // TODO:
    // Turbo visit index page before db updated due to unsubscription
    // Need a nicer way for host user not to see his deleted game in the index list
    this.channel.unsubscribe();
    // Turbo.visit(window.location.href)
  }
}
