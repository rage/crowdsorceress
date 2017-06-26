# frozen_string_literal: true

class ExerciseVerifierJob < ApplicationJob
  require 'test_generator'
  require 'main_class_generator'
  require 'rest-client'
  require 'submission_status_channel'
  queue_as :default

  rescue_from(ActiveRecord::RecordNotFound) do |_exception|
    Rails.logger.warn 'Record not found!'
  end

  def perform(exercise)
    if exercise.is_a? String
      Rails.logger.warn('ExerciseVerifierJob called with a string! Silently aborting...')
      return
    end

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
                                                                    'progress' => 0.3, 'result' => { 'OK' => false, 'error' => exercise.error_messages } }])
    exercise.testing_stub!

    File.open('StubPackage.tar', 'r') do |tar_file|
      RestClient.post post_url, file: tar_file, notify: results_url(exercise), token: 'KISSA_STUB'
    end

    SubmissionStatusChannel.broadcast_to('SubmissionStatus', JSON[{ 'status' => 'in progress', 'message' => 'Testataan malliratkaisua',
                                                                    'progress' => 0.6, 'result' => { 'OK' => false, 'error' => exercise.error_messages } }])

    exercise.testing_model_solution!

    File.open('ModelSolutionPackage.tar', 'r') do |tar_file|
      RestClient.post post_url, file: tar_file, notify: results_url(exercise), token: 'MODEL_KISSA'
    end
  end

  private

  def post_url
    ENV['SANDBOX_BASE_URL'] + '/tasks.json'
  end

  def results_url(exercise)
    "https://5c80d014.ngrok.io/exercises/#{exercise.id}/results"
  end
end
