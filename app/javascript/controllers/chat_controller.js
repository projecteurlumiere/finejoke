import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="chat"
export default class extends Controller {
  static targets = [ "form", "message", "messages" ]
  static values = {
    id: String
  }

  connect() {
    this.key = `chat_${this.idValue}`

    const chatHistory = this.#getChatHistory(this.key);

    this.messagesTarget.innerHTML = chatHistory.HTML
    console.log(this.messageTargets.length)

    this.#scrollToBottom();
    this.observer = this.#createObserver();
    if (this.messageTargets.slice(-1)[0]) this.observer.observe(this.messageTargets.slice(-1)[0])
    this.#clearChatHistories();
  }

  resetForm(e) {
    if (e.target != this.formTarget) return
    if (e.detail.success) this.formTarget.reset();
  }

  messageTargetConnected(element) {
    if (this.messageTargets.slice(-1)[0] != element) return

    if (this.messageTargets.length > 100) {
      this.messageTargets[0].remove()
    }

    const penultimateMessage = this.messageTargets.slice(-2, -1)[0]

    if (penultimateMessage) {
      this.observer.unobserve(penultimateMessage)
      if (penultimateMessage.classList.contains("currently-viewed")) {
        penultimateMessage.classList.remove("currently-viewed")
        this.#scrollToBottom();
      }
    }
    this.observer.observe(element)

    this.#storeChatHistory()
  }

  #clearChatHistories(){
    const storePeriod = 259_200_000 // three days in ms

    for (var i = 0; i < localStorage.length; i++){
      const key = localStorage.key(i)
      if (!key.startsWith("chat_") || key == this.key) continue

      const chatHistory = this.#getChatHistory(key)
      if (chatHistory.HTML === "") localStorage.removeItem(key)

      const interval = new Date - new Date(chatHistory.timestamp) 
      if (interval > storePeriod) localStorage.removeItem(key) 
    }
  }

  #scrollToBottom(){
    this.messagesTarget.scrollTo(0, this.messagesTarget.scrollHeight);
  }

  #storeChatHistory() {
    const chatHistory = JSON.stringify({
      timestamp: new Date,
      HTML: this.messagesTarget.innerHTML
    })

    localStorage.setItem(this.key, chatHistory);
  }

  #getChatHistory(key){
    const emptyHistory = {
      HTML: "",
      timestamp: new Date
    }

    try {
      const obj = JSON.parse(localStorage.getItem(key))
      if (obj) { return obj }
      return emptyHistory
    } 
    catch (e) {
      return emptyHistory
    }
  }

  #createObserver(element) {
    return new IntersectionObserver((elements) => {  
      for (var i = elements.length - 1; i >= 0; i--) {
        if (elements[i].isIntersecting) {
          elements[i].target.classList.add("currently-viewed");
        } 
        else {
          elements[i].target.classList.remove("currently-viewed");
        }
      }
    }, {
      root: this.messagesTarget,
      threshold: 0.5
    })
  }
}
