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

    if !exercise_modified?(exercise)
      exercise.error_messages.push('Tapahtui virhe: Muokkaamaton tehtävä lähetettiin uudelleen')
      SubmissionStatusChannel.broadcast_to("SubmissionStatus_user:_#{exercise.user_id}_exercise:_#{exercise.id}",
                                           JSON[{ 'status' => 'error', 'message' => 'Tee tehtävään jotain muutoksia!',
                                                  'progress' => 1, 'result' => { 'OK' => false, 'error' => exercise.error_messages } }])
      exercise.error!
    else
      send_exercise_to_sandbox(exercise)
    end
  end

  def exercise_modified?(exercise)
    if Dir.exist?(assignment_target_path(exercise)) && Dir.exist?(assignment_target_path(exercise).join("exercise_#{exercise.id}"))
      if Dir.entries(assignment_target_path(exercise).join("exercise_#{exercise.id}"))
            .include?("ModelSolution_#{exercise.id}.#{exercise.versions.last.id}.zip") ||
         Dir.entries(assignment_target_path(exercise).join("exercise_#{exercise.id}"))
            .include?("Stub_#{exercise.id}.#{exercise.versions.last.id}.zip")
      then return false
      end
    end
    true
  end

  def create_tar_files(exercise)
    exercise.create_submission

    `cd #{tmp_submission_target_path(exercise).join('model').to_s} && tar -cpf #{packages_target_path.join("ModelSolutionPackage_#{exercise.id}.tar").to_s} *`
    `cd #{tmp_submission_target_path(exercise).join('stub').to_s} && tar -cpf #{packages_target_path.join("StubPackage_#{exercise.id}.tar").to_s} *`
  end

  def send_exercise_to_sandbox(exercise)
    create_tar_files(exercise)

    # Send stub to sandbox
    send_package_to_sandbox('Testataan tehtäväpohjaa', 0.3, exercise, 'STUB', "StubPackage_#{exercise.id}.tar")

    # Send model solution to sandbox
    send_package_to_sandbox('Testataan malliratkaisua', 0.6, exercise, 'MODEL', "ModelSolutionPackage_#{exercise.id}.tar")
  end

  def send_package_to_sandbox(message, progress, exercise, token, package_name)
    SubmissionStatusChannel.broadcast_to("SubmissionStatus_user:_#{exercise.user_id}_exercise:_#{exercise.id}",
                                         JSON[{ 'status' => 'in progress', 'message' => message, 'progress' => progress,
                                                'result' => { 'OK' => false, 'error' => exercise.error_messages } }])

    token == 'STUB' ? exercise.testing_stub! : exercise.testing_model_solution!

    File.open(packages_target_path.join(package_name).to_s, 'r') do |tar_file|
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

  def assignment_target_path(exercise)
    Rails.root.join('submission_generation', 'packages', "assignment_#{exercise.assignment.id}")
  end

  def packages_target_path
    Rails.root.join('submission_generation', 'packages')
  end

  def tmp_submission_target_path(exercise)
    Rails.root.join('submission_generation', 'tmp', "Submission_#{exercise.id}")
  end
end
