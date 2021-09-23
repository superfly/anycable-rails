import { createCable } from "@anycable/web";

const cable = createCable();

async function run() {
  const channel = await cable.subscribeTo("ChatChannel")
  const _ = await channel.perform("receive")
  channel.on("message", (msg) => {
    console.log(msg)
  })
}

run()