// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

Rails.start()
Turbolinks.start()
ActiveStorage.start()

import { createCable } from '@anycable/web'

const cable = createCable()

async function run() {
  const channel = await cable.subscribeTo("ChatChannel", { roomId: "42" });
  const _ = await channel.perform("speak", { msg: "Hello" });
  channel.on("message", (msg) => {
    if (msg.type === "typing") {
      console.log(`User ${msg.name} is typing`);
    } else {
      console.log(`${msg.name}: ${msg.text}`);
    }
  });

}

run()