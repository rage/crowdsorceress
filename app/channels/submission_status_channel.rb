# frozen_string_literal: true

require 'json'
require 'application_controller'

class SubmissionStatusChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    stream_from 'SubmissionStatus'

    stream_for 'SubmissionStatus'
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  # send current status in case socket opened too late
  def receive(data)
    return unless data['ping']
    # SubmissionStatusChannel.broadcast_to('SubmissionStatus', JSON[ApplicationController.get_current_status])
  end
end
