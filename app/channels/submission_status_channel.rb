# frozen_string_literal: true

require 'json'

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
    exercise = Exercise.find(data['id'])

    SubmissionStatusChannel.broadcast_to('SubmissionStatus', JSON[submission_state(exercise)])
  end

  def submission_state(exercise)
    if exercise.nil? || exercise.status_undefined?
      state = { 'status' => 'in progress', 'message' => '(response to ping:) Yhteys tietokantaan ok, odotetaan', 'progress' => 0, 'result' => { 'OK' => false, 'error' => '' } }
    elsif exercise.saved?
      state = { 'status' => 'in progress', 'message' => '(response to ping:) Tehtävä tallennettu tietokantaan', 'progress' => 0.1, 'result' => { 'OK' => false, 'error' => '' } }
    elsif exercise.testing_stub?
      state = { 'status' => 'in progress', 'message' => '(response to ping:) Testataan tehtäväpohjaa', 'progress' => 0.3, 'result' => { 'OK' => false, 'error' => '' } }
    elsif exercise.testing_model_solution?
      state = { 'status' => 'in progress', 'message' => '(response to ping:) Testataan malliratkaisua', 'progress' => 0.5, 'result' => { 'OK' => false, 'error' => '' } }
    elsif exercise.finished?
      state = { 'status' => 'finished', 'message' => '(response to ping:) Valmis', 'progress' => 1, 'result' => { 'OK' => true, 'error' => '' } }
    elsif exercise.error?
      state = { 'status' => 'error', 'message' => '(response to ping:) Tapahtui hirvittävä virhe', 'progress' => 1, 'result' => { 'OK' => false, 'error' => 'Kuvittele tähän jonkinlainen hyödyllinen virheviesti' } }
    end
    state
  end
end
