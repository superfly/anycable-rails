import { Controller } from "@hotwired/stimulus"

import { createCable } from "@anycable/web"

const cable = createCable()

export default class extends Controller {

  static get targets() {
    return ["message"]
  }

  async connect() {
    this.channel = await cable.subscribeTo("ChatChannel")
    this.channel.on("message", (data) => {
      const e = document.createElement("div");
      e.textContent = data.msg;
      document.getElementById("messages").appendChild(e)
    })
  }
  
  async send() {
    await this.channel.perform("receive", {msg: this.messageTarget.value})
  }
}
