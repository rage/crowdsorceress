# frozen_string_literal: true

class MessageBroadcasterJob < ApplicationJob
  queue_as :default

  def perform(exercise)
    SubmissionStatusChannel.broadcast_to("SubmissionStatus_user:_#{exercise.user_id}_exercise:_#{exercise.id}",
                                         JSON[message(exercise)])
  end

  def message(exercise)
    if exercise.nil? || exercise.status_undefined?
      message_generator('in progress', 'Connection to the database established successfully, waiting', 0, false, exercise)
    elsif !exercise.assignment.show_results_to_user
      message_generator('finished', 'Submission sent!', 1, true, exercise)
    elsif exercise.saved?
      message_generator('in progress', 'Submission saved to the database', 0.1, false, exercise)
    elsif exercise.testing_template?
      message_generator('in progress', 'Testing the code template', 0.3, false, exercise)
    elsif exercise.testing_model_solution?
      message_generator('in progress', 'Testing the model solution', 0.6, false, exercise)
    elsif exercise.half_done?
      message_generator('in progress', exercise.sandbox_results[:message], 0.8, false, exercise)
    elsif exercise.finished?
      message_generator('finished', 'Finished!', 1, true, exercise)
    elsif exercise.error?
      error_message(exercise)
    elsif exercise.sandbox_timeout?
      message_generator('error', 'Sending the submission took too long', 1, false, exercise)
    end
  end

  def error_message(exercise)
    message = if !exercise.sandbox_results[:message].empty?
                'Revise and resubmit'
              else
                'An error occurred while sending the submission'
              end
    message_generator('error', message, 1, false, exercise)
  end

  def message_generator(status, message, progress, ok, exercise)
    {
      'status' => status,
      'message' => message,
      'progress' => progress,
      'result' => {
        'OK' => ok,
        'errors' => exercise.assignment.show_results_to_user ? exercise.error_messages : []
      }
    }
  end
end
