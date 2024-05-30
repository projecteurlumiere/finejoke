import { Controller } from "@hotwired/stimulus"
import { cable } from "@hotwired/turbo-rails"

export default class extends Controller {
  async initialize() {
    this.channel = (await cable.getConsumer()).subscriptions.create({ channel: "LobbyChannel" }, {
    connected() {
      // Called when the subscription is ready for use on the server
    },

    disconnected() {
      // Called when the subscription has been terminated by the server
    },

    received(data) {
      console.log("Lobby Channel says: " + data)
    }
})
  }

  connect() {
    console.log("i am connecting");
  }

  disconnect() {
    console.log("lobby disconnecting");
    this.channel.unsubscribe();
  }
}
