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
    # puts "Metodissa receive ennen broadcastia state on status " + exercise.status
    SubmissionStatusChannel.broadcast_to('SubmissionStatus', JSON[submission_state(exercise)])
  end

  def submission_state(exercise)
    # puts "Exercise id submission_staten alussa on " + exercise.id.to_s

    if exercise == nil || exercise.empty? then
      state = {'status' => 'in progress', 'message' => 'Yhteys tietokantaan ok, odotetaan', 'progress' => 0, 'result' => {'OK' => false, 'error' => ''}}
    elsif exercise.saved? then
      state = {'status' => 'in progress', 'message' => 'Exercise saved to DB', 'progress' => 0.1, 'result' => {'OK' => false, 'error' => ''}}
    elsif exercise.testing_stub? then
      state = {'status' => 'in progress', 'message' => 'Testing stub in sandbox', 'progress' => 0.3, 'result' => {'OK' => false, 'error' => ''}}
    elsif exercise.testing_model_solution? then
      state = {'status' => 'in progress', 'message' => 'Testing model solution in sandbox', 'progress' => 0.5, 'result' => {'OK' => false, 'error' => ''}}
    elsif exercise.finished? then
      state = {'status' => 'finished', 'message' => 'Valmis', 'progress' => 1, 'result' => {'OK' => true, 'error' => ''}}
    elsif exercise.error? then
      state = {'status' => 'error', 'message' => 'Tapahtui hirvittävä virhe', 'progress' => 1, 'result' => {'OK' => false, 'error' => 'Kuvittele tähän jonkinlainen hyödyllinen virheviesti'}}
    end
    # puts "Metodissa submission_state iffien jälkeen state on status " + exercise.status
    state
  end
end
