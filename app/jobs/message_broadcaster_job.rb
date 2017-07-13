# frozen_string_literal: true

class MessageBroadcasterJob < ApplicationJob
  queue_as :default

  def perform(exercise)
    SubmissionStatusChannel.broadcast_to("SubmissionStatus_user:_#{exercise.user_id}_exercise:_#{exercise.id}",
                                         JSON[message(exercise)])
  end

  def message(exercise)
    if exercise.nil? || exercise.status_undefined?
      message_generator('in progress', 'Yhteys tietokantaan ok, odotetaan', 0, false, exercise)
    elsif exercise.saved?
      message_generator('in progress', 'Tehtävä tallennettu tietokantaan', 0.1, false, exercise)
    elsif exercise.testing_stub?
      message_generator('in progress', 'Testataan tehtäväpohjaa', 0.3, false, exercise)
    elsif exercise.testing_model_solution?
      message_generator('in progress', 'Testataan malliratkaisua', 0.6, false, exercise)
    elsif exercise.finished?
      message_generator('finished', 'Valmis, kaikki on ok', 1, true, exercise)
    elsif exercise.error?
      message = if !exercise.sandbox_results[:message].empty?
                  exercise.sandbox_results[:message]
                else
                  'Tehtävän lähetyksessä tapahtui virhe'
                end
      message_generator('error', message, 1, false, exercise)
    end
  end

  def message_generator(status, message, progress, ok, exercise)
    { 'status' => status, 'message' => message, 'progress' => progress, 'result' => { 'OK' => ok, 'error' => exercise.error_messages } }
  end
end
