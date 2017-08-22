# frozen_string_literal: true

class TimeoutCheckerJob < ApplicationJob
  queue_as :default

  rescue_from(ActiveRecord::RecordNotFound) do |exception|
    puts 'NYT SAATANA ANNA TÄN TOIMII' + exception.to_s
  end

  # Checks if sandbox is done
  # Timeout happens if exercise results are not received fast enough
  def perform(exercise)
    return if exercise.finished? || exercise.error?
    exercise.error_messages.push('Timeout')
    exercise.sandbox_timeout!
    MessageBroadcasterJob.perform_now(exercise)
    puts 'tuli timeoutti'
  end
end
