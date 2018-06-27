# frozen_string_literal: true

class SandboxPosterJob
  include Sidekiq::Worker

  require 'test_generator'
  require 'rest-client'
  require 'timeout'

  sidekiq_options retry: 7
  sidekiq_retry_in do
    10
  end

  sidekiq_retries_exhausted do |msg|
    exercise = Exercise.find msg['args'][0]
    exercise.error_messages.push(header: 'The test server is congested, please try submitting the exercise again', messages: '')
    exercise.error!
    MessageBroadcasterJob.perform_now(exercise)
  end

  # maybe handle this some day
  # rescue_from(ActiveRecord::RecordNotFound) do
  #   Rails.logger.warn 'Record not found!'
  # end

  class PostFailedError < StandardError; end

  def perform(exercise_id)
    @exercise = Exercise.find(exercise_id)

    if @exercise.is_a? String
      Rails.logger.warn('SandboxPosterJob called with a string! Silently aborting...')
      return
    end

    unless @exercise.testing_model_solution? || @exercise.sandbox_results[:template_results_received]
      send_package_to_sandbox('TEMPLATE', "TemplatePackage_#{@exercise.id}.tar")
    end

    send_package_to_sandbox('MODEL', "ModelSolutionPackage_#{@exercise.id}.tar") unless @exercise.sandbox_results[:model_results_received]
    TimeoutCheckerJob.set(wait: 1.minute).perform_later(@exercise, @exercise.submit_count)
  end

  def send_package_to_sandbox(package_type, package_name)
    package_type == 'TEMPLATE' ? @exercise.testing_template! : @exercise.testing_model_solution!
    MessageBroadcasterJob.perform_now(@exercise)

    File.open(packages_target_path.join(package_name).to_s, 'r') do |tar_file|
      sandbox_post(tar_file, package_type)
    end
  end

  private

  def secret_token(package_type)
    verifier = ActiveSupport::MessageVerifier.new(Rails.application.secrets[:secret_key_base])
    verifier.generate("#{@exercise.id}#{package_type},#{@exercise.submit_count}")
  end

  def sandbox_post(tar_file, package_type)
    servers.find do |url| # could be smarter about this # we ARE smarter about this
      begin
        RestClient.post "#{url}/tasks.json", file: tar_file, notify: results_url, token: secret_token(package_type)
        logger.info "Sent package #{package_type} to sandbox #{url}"
      rescue => e
        logger.info "Posting to sandbox failed: #{e}"
        raise PostFailedError
      end
    end
  end

  def servers
    ENV['ALL_SANDBOXES'].split(',').shuffle
  end

  def results_url
    "#{ENV['BASE_URL']}/api/v0/exercises/#{@exercise.id}/results"
  end

  def packages_target_path
    Rails.root.join('submission_generation', 'packages')
  end
end
