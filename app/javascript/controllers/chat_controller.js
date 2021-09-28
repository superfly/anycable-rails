import { Controller } from "@hotwired/stimulus"
import { createCable } from "@anycable/web"
export default class extends Controller {

  static get targets() {
    return ["message"]
  }

  async connect() {
    const cable = createCable()

    try {
      this.channel = await cable.subscribeTo("ChatChannel")
      this.channel.on("message", (data) => {
        const e = document.createElement("div")
        e.textContent = data.msg;
        document.getElementById("messages").appendChild(e)
      })
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
