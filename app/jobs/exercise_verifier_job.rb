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

    send_exercise_to_sandbox(exercise)
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

  def send_exercise_to_sandbox(exercise)
    create_stub_tar(exercise)
    create_model_solution_tar(exercise)

    # Send stub to sandbox
    send_package_to_sandbox('Testataan tehtäväpohjaa', 0.3, exercise, 'KISSA_STUB', 'StubPackage.tar')

    # Send model solution to sandbox
    send_package_to_sandbox('Testataan malliratkaisua', 0.6, exercise, 'MODEL_KISSA', 'ModelSolutionPackage.tar')
  end

  def send_package_to_sandbox(message, progress, exercise, token, package_name)
    SubmissionStatusChannel.broadcast_to("SubmissionStatus_#{exercise.user_id}", JSON[{ 'status' => 'in progress', 'message' => message, 'progress' => progress,
                                                                                        'result' => { 'OK' => false, 'error' => exercise.error_messages } }])

    token == 'KISSA_STUB' ? exercise.testing_stub! : exercise.testing_model_solution!

    File.open(package_name, 'r') do |tar_file|
      sandbox_post(tar_file, exercise, token)
    end
  end

  private

  def sandbox_post(tar_file, exercise, token)
    RestClient.post post_url, file: tar_file, notify: results_url(exercise), token: token
  end

  def post_url
    ENV['SANDBOX_BASE_URL'] + '/tasks.json'
  end

  def results_url(exercise)
    "#{ENV['BASE_URL']}/exercises/#{exercise.id}/results"
  end
end
