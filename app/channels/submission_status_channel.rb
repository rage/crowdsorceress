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

    SubmissionStatusChannel.broadcast_to("SubmissionStatus_user:_#{current_user.id}_exercise:_#{current_exercise.id}", JSON[submission_state(current_exercise)])
  end

  def submission_state(exercise)
    if exercise.nil? || exercise.status_undefined?
      { 'status' => 'in progress', 'message' => '(response to ping:) Yhteys tietokantaan ok, odotetaan',
        'progress' => 0, 'result' => { 'OK' => false, 'error' => exercise.error_messages } }
    elsif exercise.saved?
      { 'status' => 'in progress', 'message' => '(response to ping:) Tehtävä tallennettu tietokantaan',
        'progress' => 0.1, 'result' => { 'OK' => false, 'error' => exercise.error_messages } }
    elsif exercise.testing_stub?
      { 'status' => 'in progress', 'message' => '(response to ping:) Testataan tehtäväpohjaa',
        'progress' => 0.3, 'result' => { 'OK' => false, 'error' => exercise.error_messages } }
    elsif exercise.testing_model_solution?
      { 'status' => 'in progress', 'message' => '(response to ping:) Testataan malliratkaisua',
        'progress' => 0.6, 'result' => { 'OK' => false, 'error' => exercise.error_messages } }
    elsif exercise.finished?
      { 'status' => 'finished', 'message' => '(response to ping:) Valmis',
        'progress' => 1, 'result' => { 'OK' => true, 'error' => exercise.error_messages } }
    elsif exercise.error?
      { 'status' => 'error', 'message' => '(response to ping:) Tapahtui hirvittävä virhe',
        'progress' => 1, 'result' => { 'OK' => false, 'error' => exercise.error_messages } }
    end
  end
end
