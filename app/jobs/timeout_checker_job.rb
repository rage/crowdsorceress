# frozen_string_literal: true

class TimeoutCheckerJob < ApplicationJob
  queue_as :default

  rescue_from(ActiveRecord::RecordNotFound) do
    Rails.logger.warn 'Record not found!'
  end

  # Checks if sandbox is done
  # Timeout happens if exercise results are not received fast enough
  def perform(exercise, submit_count)
    return if exercise.finished? || exercise.error? || exercise.submit_count != submit_count
    exercise.error_messages.push(header: 'The test server responded too slowly, please try resubmitting', messages: [{ message: '' }])
    exercise.sandbox_timeout!
    MessageBroadcasterJob.perform_now(exercise) if exercise.assignment.show_results_to_user
  end
end
