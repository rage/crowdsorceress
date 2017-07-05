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

    `cd Stub/ && tar -cpf ../packages/StubPackage#{exercise.id}.tar * && cd ..`
    puts 'Exercise id in create stub tar: ' + exercise.id.to_s
  end

  def create_model_solution_tar(exercise)
    exercise.create_file('model_solution_file')
    exercise.create_file('testfile')

    `cd ModelSolution/ && tar -cpf ../packages/ModelSolutionPackage#{exercise.id}.tar * && cd ..`
  end

  def send_exercise_to_sandbox(exercise)
    create_stub_tar(exercise)
    create_model_solution_tar(exercise)

    # Send stub to sandbox
    send_package_to_sandbox('Testataan tehtäväpohjaa', 0.3, exercise, 'KISSA_STUB', "StubPackage#{exercise.id}.tar")
    puts 'Exercise id in send exercise to sandbox: ' + exercise.id.to_s

    # Send model solution to sandbox
    send_package_to_sandbox('Testataan malliratkaisua', 0.6, exercise, 'MODEL_KISSA', "ModelSolutionPackage#{exercise.id}.tar")
  end

  def send_package_to_sandbox(message, progress, exercise, token, package_name)
    puts 'Exercise id in send package to sandbox: ' + exercise.id.to_s
    SubmissionStatusChannel.broadcast_to("SubmissionStatus_user:_#{exercise.user_id}_exercise:_#{exercise.id}",
                                         JSON[{ 'status' => 'in progress', 'message' => message, 'progress' => progress,
                                                'result' => { 'OK' => false, 'error' => exercise.error_messages } }])

    token == 'KISSA_STUB' ? exercise.testing_stub! : exercise.testing_model_solution!

    File.open('./packages/' + package_name, 'r') do |tar_file|
      sandbox_post(tar_file, exercise, token)
    end
  end

  private

  def sandbox_post(tar_file, exercise, token)
    response = RestClient.post post_url, file: tar_file, notify: results_url(exercise), token: token

    `rm #{tar_file.path}`

    return unless response.code != 200
    exercise.error_messages.push 'Error in posting exercise to sandbox'
    SubmissionStatusChannel.broadcast_to("SubmissionStatus_user:_#{exercise.user_id}_exercise:_#{exercise.id}",
                                         JSON[{ 'status' => 'error', 'message' => 'Ongelmia palvelimessa, yritä jonkin ajan päästä uudelleen.',
                                                'progress' => 1, 'result' => { 'OK' => false, 'error' => exercise.error_messages } }])
  end

  def post_url
    ENV['SANDBOX_BASE_URL'] + '/tasks.json'
  end

  def results_url(exercise)
    "#{ENV['BASE_URL']}/exercises/#{exercise.id}/results"
  end
end
