# frozen_string_literal: true

class Exercise < ApplicationRecord
  belongs_to :assignment
  belongs_to :user

  require 'zip'
  require 'tmc_langs'
  require 'sandbox_results_handler'

  has_paper_trail ignore: %i[updated_at status error_messages sandbox_results]

  validates :description, presence: true
  validates :testIO, presence: true
  validates :code, presence: true

  serialize :sandbox_results, Hash

  enum status: %i[status_undefined saved testing_stub testing_model_solution finished error]

  def reset!
    self.error_messages = []
    status_undefined!
    self.sandbox_results = { status: '', message: '', passed: false, model_results_received: false, stub_results_received: false }
  end

  def create_submission
    if !Dir.exist?(submission_target_path.to_s)
    then FileUtils.cp_r Rails.root.join('submission_generation', 'SubmissionTemplate').to_s, submission_target_path.to_s
    else
      FileUtils.remove_dir(submission_target_path.join('model').to_s)
      FileUtils.remove_dir(submission_target_path.join('stub').to_s)
    end

    write_to_file(submission_target_path.join('src', 'Submission.java').to_s, MainClassGenerator.new, 'Submission')
    write_to_file(submission_target_path.join('test', 'SubmissionTest.java').to_s, TestGenerator.new, 'Submission')

    create_model_solution_and_stub
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

  def handle_results(sandbox_status, test_output, token)
    SandboxResultsHandler.new(self).handle(sandbox_status, test_output, token)

    if sandbox_results[:model_results_received] && sandbox_results[:stub_results_received]
    then send_results_to_frontend(sandbox_results[:status], 1, sandbox_results[:passed])
    else send_results_to_frontend('in progress', 0.8, false)
    end
  end

  def send_results_to_frontend(status, progress, passed)
    results = { 'status' => status, 'message' => sandbox_results[:message], 'progress' => progress,
                'result' => { 'OK' => passed, 'error' => error_messages } }

    SubmissionStatusChannel.broadcast_to("SubmissionStatus_user:_#{user_id}_exercise:_#{id}", JSON[results])

    status == 'finished' && passed ? finished! : error!

    clean_up if finished?
  end

  def clean_up
    create_directories_for_zips

    create_zip(assignment_target_path.join("exercise_#{id}", "Stub_#{id}.#{versions.last.id}.zip").to_s, 'stub')
    create_zip(assignment_target_path.join("exercise_#{id}", "ModelSolution_#{id}.#{versions.last.id}.zip").to_s, 'model')

    FileUtils.remove_dir(submission_target_path.to_s)
  end

  def create_directories_for_zips
    return if Dir.exist?(assignment_target_path.to_s)
    Dir.mkdir(assignment_target_path.to_s)

    return if Dir.exist?(assignment_target_path.join("exercise_#{id}").to_s)
    Dir.mkdir(assignment_target_path.join("exercise_#{id}").to_s)
  end

  def create_zip(zipfile_name, file)
    input_files = ['lib/testrunner/tmc-junit-runner.jar', 'lib/edu-test-utils-0.4.2.jar', 'lib/junit-4.10.jar',
                   'nbproject/build-impl.xml', 'nbproject/genfiles.properties', 'nbproject/project.properties',
                   'nbproject/project.xml', 'src/Submission.java', 'test/SubmissionTest.java', 'build.xml']

    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      input_files.each do |name|
        zipfile.add(name, submission_target_path.join(file.to_s, name.to_s).to_s)
      end
    end
  end

  def in_progress?
    %i[saved testing_stub testing_model_solution].include?(status)
  end

  def assignment_target_path
    Rails.root.join('submission_generation', 'packages', "assignment_#{assignment.id}")
  end

  def submission_target_path
    Rails.root.join('submission_generation', 'tmp', "Submission_#{id}")
  end
end
