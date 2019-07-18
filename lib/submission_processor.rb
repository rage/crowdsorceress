class SubmissionProcessor

  class PostFailedError < StandardError;
  end

  def process_submission(exercise)
    @exercise = exercise
    @exercise.processing_tried_at = Time.now
    @exercise.save!

    try_to_send_submission_to_free_server
    @exercise.processing_began_at = Time.now
    @exercise.times_sent_to_sandbox += 1
    @exercise.save!
    Rails.logger.info "Submission #{@exercise.id} sent to sandbox."
  end

  def process_some_submissions
    submissions = Exercise.where(status: %w[saved testing_model_solution half_done sandbox_timeout]) # testing_template

    submissions.limit(2).each do |submission|
      Rails.logger.info "Attempting to process submission #{submission.id}"

      if submission.times_sent_to_sandbox < 8
        process_submission(submission)
      else
        submission.error_messages.push(header: 'The test server is congested, please try resubmitting later', messages: [{message: ''}])
        submission.sandbox_timeout!
        MessageBroadcasterJob.perform_now(submission) if submission.assignment.show_results_to_user
      end
    end
  end

  def try_to_send_submission_to_free_server
=begin
    unless @exercise.testing_model_solution? || @exercise.sandbox_results[:template_results_received]
      send_package_to_sandbox('TEMPLATE', "TemplatePackage_#{@exercise.id}.tar")
    end
=end
    send_package_to_sandbox('MODEL', "ModelSolutionPackage_#{@exercise.id}.tar") unless @exercise.sandbox_results[:model_results_received]
  end

  def send_package_to_sandbox(package_type, package_name)
    @exercise.testing_model_solution! # package_type == 'TEMPLATE' ? @exercise.testing_template! :
    MessageBroadcasterJob.perform_now(@exercise) if @exercise.assignment.show_results_to_user

    File.open(packages_target_path.join(package_name).to_s, 'r') do |tar_file|
      sandbox_post(tar_file, package_type)
    end
  end

  def sandbox_post(tar_file, package_type)
    servers.find do |url|
      begin
        RestClient.post "#{url}/tasks.json", file: tar_file, notify: results_url, token: secret_token(package_type)
        Rails.logger.info "Sent package #{package_type} to sandbox #{url}"
      rescue => e
        Rails.logger.info "Posting to sandbox failed: #{e}"
        raise PostFailedError
      end
    end
  end

  private

  def secret_token(package_type)
    verifier = ActiveSupport::MessageVerifier.new(Rails.application.secrets[:secret_key_base])
    verifier.generate("#{@exercise.id}#{package_type},#{@exercise.submit_count}")
  end

  def servers
    ENV['SANDBOX_URL'].split(',').shuffle
  end

  def results_url
    "#{ENV['BASE_URL']}/api/v0/exercises/#{@exercise.id}/results"
  end

  def packages_target_path
    Rails.root.join('submission_generation', 'packages')
  end
end
