import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="chat"
export default class extends Controller {
  static targets = [ "form", "message", "messages" ]
  static values = {
    id: String
  }

  connect() {
    this.key = `chat_${this.idValue}`

    this.scrollObserver = this.#createScrollObserver();

    this.#restoreChatHistory();

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
    const lastMessage = this.#lastMessage()
    if (lastMessage != element) return

    this.#removeExcess();

    const penultimateMessage = this.messageTargets.slice(-2, -1)[0]

    if (penultimateMessage) {
      if (penultimateMessage.classList.contains("currently-viewed")) {
        this.#scrollToBottom();
      } 
    }

    this.scrollObserver.observe(element);

    setTimeout(() => {
      if (lastMessage.classList.contains("unseen")) { 
        this.dispatch("unseen", { detail: { containerName: this.element.dataset.containerName } })
      }
    }, 100)

    this.#insertTime(lastMessage);
    this.#storeChatHistory()
  }

  adjustScrollOnResize(e){
    if (!this.#lastMessage() || this.#lastMessage().classList.contains("currently-viewed")) {
      this.#scrollToBottom();
    }
  }

  #lastMessage() {
    return this.messageTargets.slice(-1)[0]
  }

  #restoreChatHistory() {
    const chatHistory = this.#getChatHistory(this.key);
    this.messagesTarget.innerHTML = chatHistory.HTML
    this.#removeExcess();
    for (var i = this.messageTargets.length - 1; i >= 0; i--) {
      this.messageTargets[i].classList.remove("unseen")
      this.scrollObserver.observe(this.messageTargets[i])
    }
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

  #insertTime(element) {
    if (element.querySelector("time")) return

    let node = document.createElement("time")
    const now = new Date
    node.innerText = `${String(now.getHours()).padStart(2, "0")}:${String(now.getMinutes()).padStart(2, "0")}`

    element.querySelector(".username").insertAdjacentElement("afterend", node)
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
          if (window.getComputedStyle(this.element).display === "none" && elements[i].target === lastMessage && this.#noneIsIntersecting(elements) && lastMessage.classList.contains("currently-viewed")) {
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

  #noneIsIntersecting(elements) {
    for (var i = elements.length - 1; i >= 0; i--) {
      if (elements[i].isIntersecting) return false
    }
    return true
  }
}
