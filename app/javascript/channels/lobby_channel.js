// import consumer from "channels/consumer"

// consumer.subscriptions.create({ channel: "LobbyChannel" }, {
//   connected() {
//     // Called when the subscription is ready for use on the server
//   },

//   disconnected() {
//     // Called when the subscription has been terminated by the server
//   },

//   received(data) {
//     console.log("Lobby Channel says: " + data)
//   }
// })

// import { cable } from "@hotwired/turbo-rails"

// (await cable.getConsumer()).subscriptions.create({ channel: "LobbyChannel" }, {
//   connected() {
//     // Called when the subscription is ready for use on the server
//   },

//   disconnected() {
//     // Called when the subscription has been terminated by the server
//   },

//   received(data) {
//     console.log("Lobby Channel says: " + data)
//   }
// })