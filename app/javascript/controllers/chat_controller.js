import { Controller } from "@hotwired/stimulus"
import { createCable } from "@anycable/web"
export default class extends Controller {

  static get targets() {
    return ["message", "loading", "container"]
  }

  async connect() {
    const cable = createCable()

    try {
      this.channel = await cable.subscribeTo("ChatChannel")
      this.channel.on("message", (data) => {
        const e = document.createElement("div")
        e.setAttribute("class", "my-2 bg-purple-100 rounded-md py-1 px-3")
        e.textContent = data.msg;
        document.getElementById("messages").appendChild(e)
      })
      this.loadingTarget.classList.add("hidden")
      this.containerTarget.classList.remove("hidden")
    } catch (e) {
      console.log(e)
    }
  }

  enter(event) {
     if (event.keyCode == 13) {
        this.send()
        event.preventDefault()
      }
  }
  
  async send() {
    await this.channel.perform("receive", {msg: this.messageTarget.value})
    this.messageTarget.value = ""
  }
}
