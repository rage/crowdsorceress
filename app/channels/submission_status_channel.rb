# frozen_string_literal: true
require 'json'

class SubmissionStatusChannel < ApplicationCable::Channel

  def subscribed
    # stream_from "some_channel"
    stream_from "SubmissionStatus"
    stream_for "SubmissionStatus"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  # send current status in case socket opened too late
  def receive(data)
    return unless data["ping"]
    test_subscription
  end


  private
  def test_subscription
    data = {
      'message'=> "pong1",
      'progress'=> 0,
    }

    SubmissionStatusChannel.broadcast_to("SubmissionStatus", JSON[data]
    )

    sleep 15

    data1 = {
      'message'=> "pong2",
      'progress'=> 1,
    }
    SubmissionStatusChannel.broadcast_to("SubmissionStatus", JSON[data1]
    )
  end

end
