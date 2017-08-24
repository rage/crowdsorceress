# frozen_string_literal: true

class TimeoutCheckerJob < ApplicationJob
  queue_as :default

  rescue_from(ActiveRecord::RecordNotFound) do
    Rails.logger.warn 'Record not found!'
  end

  # Checks if sandbox is done
  # Timeout happens if exercise results are not received fast enough
  def perform(exercise)
    return if exercise.finished? || exercise.error?

    if exercise.times_sent_to_sandbox < 3
      send_again(exercise)
      Rails.logger.info "sending again for the #{exercise.times_sent_to_sandbox + 1}. time"
    else
      exercise.error_messages.push(header: 'System error', messages: '')
      exercise.sandbox_timeout!
      MessageBroadcasterJob.perform_now(exercise)
    end
  end

  def send_again(exercise)
    ExerciseVerifierJob.perform_now(exercise)
  end
end
