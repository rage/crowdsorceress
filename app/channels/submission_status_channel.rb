# frozen_string_literal: true

class SubmissionStatusChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    stream_from "SubmissionStatus"
    stream_for "SubmissionStatus"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
