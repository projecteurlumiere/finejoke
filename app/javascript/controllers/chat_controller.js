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
    this.#removeExcess();
    this.scrollObserver = this.#createScrollObserver();
    for (var i = this.messageTargets.length - 1; i >= 0; i--) {
      this.messageTargets[i].classList.remove("unseen")
      this.scrollObserver.observe(this.messageTargets[i])
    }

    this.mustScrollToBottom = true
    setTimeout(() => { this.#scrollToBottom(); }, 100)
    this.#clearChatHistories();
  }

  resetForm(e) {
    if (e.target != this.formTarget) return
    if (e.detail.success) {
      this.#scrollToBottom();
      this.formTarget.reset();
    }
  }

  messageTargetConnected(element) {
    if (this.#lastMessage() != element) return

    this.#removeExcess();

    const penultimateMessage = this.messageTargets.slice(-2, -1)[0]

    if (!penultimateMessage || penultimateMessage.classList.contains("currently-viewed")) {
      this.#scrollToBottom();
    }

    this.scrollObserver.observe(element);

    setTimeout(() => {
      if (this.#lastMessage().classList.contains("unseen")) { 
        this.dispatch("unseen", { detail: { containerName: this.element.dataset.containerName } })
      }
    }, 100)

    this.#storeChatHistory()
  }

  adjustScrollOnResize(e){
    if (this.#lastMessage().classList.contains("currently-viewed")) {
      this.#scrollToBottom();
    }
  }

  #lastMessage() {
    return this.messageTargets.slice(-1)[0]
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

  #removeExcess(){
    if (this.messageTargets.length > 100) {
      const oldMessages = this.messageTargets.slice(0, -100)

      for (var i = oldMessages.length - 1; i >= 0; i--) {
        if (this.scrollObserver) {
          this.scrollObserver.unobserve(oldMessages[i])
        }

        oldMessages[i].remove()
      }
    }
  }

  #scrollToBottom(){
    this.messagesTarget.scrollTo(0, this.messagesTarget.scrollHeight);
    for (var i = this.messageTargets.length - 1; i >= 0; i--) {
      this.messageTargets[i].classList.remove("unseen")
    }
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

  #createScrollObserver() {
    return new IntersectionObserver((elements) => {  
      const lastMessage = this.#lastMessage()

      for (var i = elements.length - 1; i >= 0; i--) {
        if (elements[i].isIntersecting) {
          elements[i].target.classList.add("currently-viewed");
          elements[i].target.classList.remove("unseen");
          if (elements[i].target === lastMessage) {
            this.dispatch("seen", { detail: { containerName: this.element.dataset.containerName } })
          }
        } 
        else {
          if (this.element.classList.contains("hidden-when-mobile") && elements[i] === lastMessage) {
            this.mustScrollToBottom = true
          }
          elements[i].target.classList.remove("currently-viewed");
        }
      }

      if (!this.element.classList.contains("hidden-when-mobile") && this.mustScrollToBottom) { 
        this.mustScrollToBottom = false;
        this.#scrollToBottom();
      }
    }, {
      root: this.messagesTarget,
      threshold: 0.5
    })
  }
}
