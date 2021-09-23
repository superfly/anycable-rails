class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "ChatChannel"
  end

  def receive
    ActionCable.server.broadcast('ChatChannel', "received")
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
