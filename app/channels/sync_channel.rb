class SyncChannel < ApplicationCable::Channel
  def subscribed
    stream_from "sync_status"
  end
end