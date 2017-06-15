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
      'message'=> "Saved exercice to DB",
      'progress'=> 0.05,
      'finished'=> false
    }

    SubmissionStatusChannel.broadcast_to("SubmissionStatus", JSON[data]
    )

    sleep 5

    data1 = {
      'message'=> "Testing",
      'progress'=> 0.5,
      'finished'=> false,
    }
    SubmissionStatusChannel.broadcast_to("SubmissionStatus", JSON[data1]
    )

    sleep 5

    data1 = {
      'message'=> "All tests passed!",
      'progress'=> 1,
      'finished'=> true,
    }
    SubmissionStatusChannel.broadcast_to("SubmissionStatus", JSON[data1]
    )

  end

end
