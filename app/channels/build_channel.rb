# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class BuildChannel < ApplicationCable::Channel
  def subscribed
    stream_from "build_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def notify(data)
    ActionCable.server.broadcast 'build_channel', options: data
  end
end
