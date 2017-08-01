# frozen_string_literal: true

class Exercise < ApplicationRecord
  belongs_to :assignment
  belongs_to :user
  has_many :peer_reviews
  has_many :exercises_tags, dependent: :destroy
  has_many :tags, through: :exercises_tags

  require 'tmc_langs'
  require 'sandbox_results_handler'
  require 'zip_handler'

  has_paper_trail ignore: %i[updated_at status error_messages sandbox_results]

  validates :description, presence: true
  validates :testIO, presence: true
  validates :code, presence: true

  serialize :sandbox_results, Hash

  enum status: %i[status_undefined saved testing_stub testing_model_solution half_done finished error]

  def reset!
    self.error_messages = []
    status_undefined!
    self.sandbox_results = { status: '', message: '', passed: false, model_results_received: false, stub_results_received: false }
  end

  def create_submission
    check_if_already_submitted

    write_to_file(submission_target_path.join('src', 'Submission.java').to_s, MainClassGenerator.new, 'Submission')
    write_to_file(submission_target_path.join('test', 'SubmissionTest.java').to_s, TestGenerator.new, 'Submission')

    create_model_solution_and_stub
  end

  def check_if_already_submitted
    if !Dir.exist?(submission_target_path.to_s)
    then FileUtils.cp_r Rails.root.join('submission_generation', 'SubmissionTemplate').to_s, submission_target_path.to_s
    else
      FileUtils.remove_dir(submission_target_path.join('model').to_s)
      FileUtils.remove_dir(submission_target_path.join('stub').to_s)
    end
  end

  def create_model_solution_and_stub
    TMCLangs.prepare_solutions(self)
    TMCLangs.prepare_stubs(self)
  end

  def write_to_file(filename, generator, class_name)
    file = File.new(filename, 'w+')
    file.close

    File.open(filename, 'w') do |f|
      f.write(generator.generate(self, class_name))
    end
  end

  def handle_results(sandbox_status, test_output, package_type)
    SandboxResultsHandler.new(self).handle(sandbox_status, test_output, package_type)

    if sandbox_results[:model_results_received] && sandbox_results[:stub_results_received]
      sandbox_status == 'finished' && sandbox_results[:passed] ? finished! : error!
    else
      half_done!
    end
    send_results_to_frontend
  end

  def send_results_to_frontend
    MessageBroadcasterJob.perform_now(self)
    ZipHandler.new(self).clean_up if finished?
  end

  def in_progress?
    %w[saved testing_stub testing_model_solution half_done].include?(status)
  end

  def submission_target_path
    Rails.root.join('submission_generation', 'tmp', "Submission_#{id}")
  end
end
