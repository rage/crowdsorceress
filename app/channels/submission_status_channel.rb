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
  end

  def message(exercise)
    if exercise.nil? || exercise.status_undefined?
      message_generator('in progress', '(response to ping:) Yhteys tietokantaan ok, odotetaan', 0, false, exercise)
    elsif exercise.saved?
      message_generator('in progress', '(response to ping:) Tehtävä tallennettu tietokantaan', 0.1, false, exercise)
    elsif exercise.testing_stub?
      message_generator('in progress', '(response to ping:) Testataan tehtäväpohjaa', 0.3, false, exercise)
    elsif exercise.testing_model_solution?
      message_generator('in progress', '(response to ping:) Testataan malliratkaisua', 0.6, false, exercise)
    elsif exercise.half_done?
      message_generator('in progress', exercise.sandbox_results[:message], 0.8, false, exercise)
    elsif exercise.finished?
      message_generator('finished', '(response to ping:) Valmis, kaikki on ok', 1, true, exercise)
    elsif exercise.error?
      error_message(exercise)
    elsif exercise.processing?
      message_generator('finished', '(response to ping:) Edellisen lähetetyn tehtävän käsittely on vielä kesken, odota', 0.05, false, exercise )
    end
  end

  def error_message(exercise)
    message = if !exercise.sandbox_results[:message].empty?
                exercise.sandbox_results[:message]
              else
                '(response to ping:) Tehtävän lähetyksessä tapahtui virhe'
              end
    message_generator('error', message, 1, false, exercise)
  end

  def message_generator(status, message, progress, ok, exercise)
    { 'status' => status, 'message' => message, 'progress' => progress, 'result' => { 'OK' => ok, 'error' => exercise.error_messages } }
  end
end
