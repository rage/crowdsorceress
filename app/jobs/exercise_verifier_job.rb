# frozen_string_literal: true

class ExerciseVerifierJob < ApplicationJob
  require 'test_generator'
  require 'main_class_generator'
  require 'rest-client'
  require 'submission_status_channel'
  queue_as :default

  rescue_from(ActiveRecord::RecordNotFound) do |_exception|
    puts 'RECORD NOT FOUND TROLOLOLO'
  end

  def perform(exercise)
    if exercise.is_a? String
      Rails.logger.warn('ExerciseVerifierJob called with a string! Silently aborting...')
      return
    end
    puts 'EXERCISE ID: ' + exercise.id.to_s
    puts 'Performing! omg'

    send_to_sandbox(exercise)
  end

  def create_stub_tar(exercise)
    exercise.create_file('stubfile')

    `cd Stub/ && tar -cpf ../StubPackage.tar * && cd ..`
  end

  def create_model_solution_tar(exercise)
    exercise.create_file('model_solution_file')
    exercise.create_file('testfile')

    `cd ModelSolution/ && tar -cpf ../ModelSolutionPackage.tar * && cd ..`
  end

  def send_to_sandbox(exercise)
    create_stub_tar(exercise)
    create_model_solution_tar(exercise)

    SubmissionStatusChannel.broadcast_to('SubmissionStatus', JSON[{ 'status' => 'in progress', 'message' => 'Testataan tehtäväpohjaa',
                                                                    'progress' => 0.5, 'result' => { 'OK' => false, 'error' => exercise.error_messages } }])
    exercise.testing_stub!

    puts 'Sending stub to sandbox'

    File.open('StubPackage.tar', 'r') do |tar_file|
      RestClient.post post_url, file: tar_file, notify: " https://5baab9e2.ngrok.io/exercises/#{exercise.id}/results", token: 'KISSA_STUB'
    end

    puts 'Sent stub to sandbox'

    SubmissionStatusChannel.broadcast_to('SubmissionStatus', JSON[{ 'status' => 'in progress', 'message' => 'Testataan malliratkaisua',
                                                                    'progress' => 0.7, 'result' => { 'OK' => false, 'error' => exercise.error_messages } }])

    exercise.testing_model_solution!

    puts 'Sending model solution to sandbox'

    File.open('ModelSolutionPackage.tar', 'r') do |tar_file|
      RestClient.post post_url, file: tar_file, notify: " https://8c0ef1e4.ngrok.io/exercises/#{exercise.id}/results", token: 'MODEL_KISSA'
    end

    puts 'Sent model solution to sandbox'
  end

  private

  def post_url
    ENV['SANDBOX_BASE_URL'] + '/tasks.json'
  end
end
