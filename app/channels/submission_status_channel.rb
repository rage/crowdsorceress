# frozen_string_literal: true

require 'json'

class SubmissionStatusChannel < ApplicationCable::Channel
  def subscribed
    stream_for "SubmissionStatus_user:_#{current_user.id}_exercise:_#{current_exercise.id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  # send current status in case socket opened too late
  def receive(data)
    return unless data['ping']
    SubmissionStatusChannel.broadcast_to("SubmissionStatus_user:_#{current_user.id}_exercise:_#{current_exercise.id}", JSON[message(current_exercise)])
    SubmissionStatusChannel.broadcast_to("SubmissionStatus_user:_#{current_user.id}_exercise:_#{current_exercise.id}", JSON[message(current_exercise)])
  end

  def message(exercise)
    if exercise.nil? || exercise.status_undefined?
      message_generator('in progress', 'Connection to database established, waiting', 0, false, exercise)
    elsif exercise.saved?
      message_generator('in progress', 'Exercise saved to database', 0.1, false, exercise)
    elsif exercise.testing_template?
      message_generator('in progress', 'Testing code template', 0.3, false, exercise)
    elsif exercise.testing_model_solution?
      message_generator('in progress', 'Testing model solution', 0.6, false, exercise)
    elsif exercise.half_done?
      message_generator('in progress', exercise.sandbox_results[:message], 0.8, false, exercise)
    elsif exercise.finished?
      message_generator('finished', 'Finished, everything is ok', 1, true, exercise)
    elsif exercise.error?
      error_message(exercise)
    elsif exercise.sandbox_timeout?
      message_generator('error', 'Sending the submission took too long', 1, false, exercise)
    end
  end

  def error_message(exercise)
    message = if !exercise.sandbox_results[:message].empty?
                exercise.sandbox_results[:message]
              else
                'An error occurred during the submission process'
              end
    message_generator('error', message, 1, false, exercise)
  end

  def message_generator(status, message, progress, ok, exercise)
    { 'status' => status, 'message' => message, 'progress' => progress, 'result' => { 'OK' => ok, 'errors' => exercise.error_messages } }
  end
end
