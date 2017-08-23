# frozen_string_literal: true

class ExerciseVerifierJob < ApplicationJob
  require 'test_generator'
  require 'main_class_generator'
  require 'rest-client'
  require 'submission_status_channel'
  require 'timeout'
  queue_as :default

  rescue_from(ActiveRecord::RecordNotFound) do
    Rails.logger.warn 'Record not found!'
  end

  def perform(exercise)
    if exercise.is_a? String
      Rails.logger.warn('ExerciseVerifierJob called with a string! Silently aborting...')
      return
    end

    if !exercise_modified?(exercise)
      exercise.error_messages.push(header: 'Tapahtui virhe: Muokkaamaton tehtävä lähetettiin uudelleen')
      exercise.error!
      MessageBroadcasterJob.perform_now(exercise)
    else
      send_exercise_to_sandbox(exercise)
    end
  end

  def exercise_modified?(exercise)
    if Dir.exist?(assignment_target_path(exercise)) && Dir.exist?(assignment_target_path(exercise).join("exercise_#{exercise.id}"))
      if directory_includes_file(exercise, 'ModelSolution') || directory_includes_file(exercise, 'Template')
        return false
      end
    end
    true
  end

  def directory_includes_file(exercise, package_type)
    Dir.entries(assignment_target_path(exercise).join("exercise_#{exercise.id}")).include?("#{package_type}_#{exercise.id}.#{exercise.versions.last.id}.zip")
  end

  def create_tar_files(exercise)
    exercise.create_submission

    `cd #{tmp_submission_target_path(exercise).join('model').to_s} && tar -cpf #{packages_target_path.join("ModelSolutionPackage_#{exercise.id}.tar").to_s} *`
    `cd #{tmp_submission_target_path(exercise).join('template').to_s} && tar -cpf #{packages_target_path.join("TemplatePackage_#{exercise.id}.tar").to_s} *`
  end

  def send_exercise_to_sandbox(exercise)
    create_tar_files(exercise)

    # Send template to sandbox
    send_package_to_sandbox(exercise, 'TEMPLATE', "TemplatePackage_#{exercise.id}.tar")

    # Send model solution to sandbox
    send_package_to_sandbox(exercise, 'MODEL', "ModelSolutionPackage_#{exercise.id}.tar")
  end

  def send_package_to_sandbox(exercise, package_type, package_name)
    package_type == 'TEMPLATE' ? exercise.testing_template! : exercise.testing_model_solution!

    MessageBroadcasterJob.perform_now(exercise)

    File.open(packages_target_path.join(package_name).to_s, 'r') do |tar_file|
      sandbox_post(tar_file, exercise, package_type)
    end
  end

  private

  def secret_token(exercise, package_type)
    verifier = ActiveSupport::MessageVerifier.new(Rails.application.secrets[:secret_key_base])

    verifier.generate(exercise.id) + package_type
  end

  def sandbox_post(tar_file, exercise, package_type)
    response = RestClient.post post_url, file: tar_file, notify: results_url(exercise), token: secret_token(exercise, package_type)

    `rm #{tar_file.path}`

    return unless response.code != 200
    exercise.error_messages.push(header: 'Ongelmia palvelimessa, yritä jonkin ajan päästä uudelleen')
    MessageBroadcasterJob.perform_now(exercise)
  end

  def post_url
    ENV['SANDBOX_BASE_URL'] + '/tasks.json'
  end

  def results_url(exercise)
    "#{ENV['BASE_URL']}/api/v0/exercises/#{exercise.id}/results"
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
