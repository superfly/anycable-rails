class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "ChatChannel"
  end

  def receive(msg)
    logger.info(msg)
    ActionCable.server.broadcast('ChatChannel', msg)
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
