# frozen_string_literal: true

class ExerciseVerifierJob < ApplicationJob
  require 'main_class_generator'
  require 'test_generator'
  require 'rest-client'
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
    exercise.times_sent_to_sandbox += 1
    exercise.save!
    send_package_to_sandbox(exercise, 'TEMPLATE', "TemplatePackage_#{exercise.id}.tar")
    send_package_to_sandbox(exercise, 'MODEL', "ModelSolutionPackage_#{exercise.id}.tar")
  end

  def send_package_to_sandbox(exercise, package_type, package_name)
    package_type == 'TEMPLATE' ? exercise.testing_template! : exercise.testing_model_solution!
    if exercise.times_sent_to_sandbox == 1
      MessageBroadcasterJob.perform_now(exercise)
    end

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

    return unless response.code != 200
    exercise.error_messages.push(header: 'Ongelmia palvelimessa, yritä jonkin ajan päästä uudelleen')
    MessageBroadcasterJob.perform_now(exercise)
  end

  def post_url
    sandbox_base = ENV['ALL_SANDBOXES'].split(',').sample

    sandbox_base + '/tasks.json' # could be smarter about this
    # ENV['SANDBOX_BASE_URL'] + '/tasks.json'
  end

  def results_url(exercise)
    "#{ENV['BASE_URL']}/api/v0/exercises/#{exercise.id}/results"
  end

  def packages_target_path
    Rails.root.join('submission_generation', 'packages')
  end
end
