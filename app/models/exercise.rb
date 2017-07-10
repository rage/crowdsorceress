# frozen_string_literal: true

class Exercise < ApplicationRecord
  belongs_to :assignment
  belongs_to :user

  require 'zip'
  require 'tmc_langs'

  validates :description, presence: true
  validates :testIO, presence: true
  validates :code, presence: true

  serialize :sandbox_results, Hash

  enum status: %i[status_undefined saved testing_stub testing_model_solution finished error]

  def create_submission
    if !Dir.exist?(Rails.root.join('submission_generation', 'tmp', "Submission_#{id}"))
    then FileUtils.cp_r Rails.root.join('submission_generation', 'SubmissionTemplate'), Rails.root.join('submission_generation', 'tmp', "Submission_#{id}/")
    else
      FileUtils.remove_dir(Rails.root.join('submission_generation', 'tmp', "Submission_#{id}", 'model'))
      FileUtils.remove_dir(Rails.root.join('submission_generation', 'tmp', "Submission_#{id}", 'stub'))
    end

    write_to_file(Rails.root.join('submission_generation', 'tmp', "Submission_#{id}", 'src', 'Submission.java'), MainClassGenerator.new, 'Submission')
    write_to_file(Rails.root.join('submission_generation', 'tmp', "Submission_#{id}", 'test', 'SubmissionTest.java'), TestGenerator.new, 'Submission')

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
    exercise_errors(test_output, token)
    generate_data_for_frontend(sandbox_status, test_output, token)

    if sandbox_results[:model_results_received] && sandbox_results[:stub_results_received]
    then send_results_to_frontend(sandbox_results[:status], 1, sandbox_results[:passed])
    else send_results_to_frontend('in progress', 0.8, false)
    end
  end

  def generate_data_for_frontend(sandbox_status, test_output, token)
    generate_message(sandbox_status, test_output['status'] == 'PASSED', test_output['status'] != 'COMPILE_FAILED', token)

    # Status will be 'finished' if both stub results and model solution results are finished in sandbox
    if sandbox_results[:status] == '' || sandbox_results[:status] == 'finished'
      sandbox_results[:status] = sandbox_status
    end

    # Model solution is passed if test results are passed
    sandbox_results[:passed] = true unless test_output['status'] != 'PASSED'

    # Update exercise's sandbox_results
    save!
  end

  def exercise_errors(test_output, token)
    test_results(test_output) if token == 'MODEL'
    compile_errors(test_output, token)
  end

  def test_results(test_output)
    # Push test results into exercise's error messages
    return if test_output['testResults'].empty? || test_output['testResults'].first['successful']
    error_messages.push 'Virheet testeissä: '
    test_output['testResults'].each do |e|
      error_messages.push e['message']
    end
  end

  def compile_errors(test_output, token)
    # Push compile errors into exercise's error messages
    return unless test_output['status'] == 'COMPILE_FAILED'

    token == 'STUB' ? (error_messages.push 'Tehtäväpohja ei kääntynyt: ') : (error_messages.push 'Malliratkaisu ei kääntynyt: ')

    error_message_lines = test_output['logs']['stdout'].pack('c*').slice(/(?<=do-compile:\n)(.*?\n)*(.*$)/).split(/\n/)
    error_message_lines.each do |line|
      error_messages.push line
    end
  end

  # Generate message that will be sent to frontend
  def generate_message(sandbox_status, passed, compiled, token)
    if token == 'STUB'
      sandbox_results[:message] += ' Tehtäväpohjan tulokset: '
      sandbox_results[:stub_results_received] = true
    else
      sandbox_results[:message] += ' Malliratkaisun tulokset: '
      sandbox_results[:model_results_received] = true
    end
    sandbox_results[:message] += if sandbox_status == 'finished' && passed then 'Kaikki OK.'
                                 elsif sandbox_status == 'finished' && compiled && token == 'MODEL' then 'Testit eivät menneet läpi.'
                                 else
                                   'Koodi ei kääntynyt.'
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
    if File.exist?("./submission_generation/packages/Stub_#{id}.zip")
      FileUtils.rm("./submission_generation/packages/Stub_#{id}.zip")
    end

    if File.exist?("./submission_generation/packages/ModelSolution_#{id}.zip")
      FileUtils.rm("./submission_generation/packages/ModelSolution_#{id}.zip")
    end

    create_zip("./submission_generation/packages/Stub_#{id}.zip", 'stub')
    create_zip("./submission_generation/packages/ModelSolution_#{id}.zip", 'model')

    FileUtils.remove_dir("./submission_generation/tmp/Submission_#{id}")
  end

  def create_zip(zipfile_name, file)
    input_files = ['lib/testrunner/tmc-junit-runner.jar', 'lib/edu-test-utils-0.4.2.jar', 'lib/junit-4.10.jar',
                   'nbproject/build-impl.xml', 'nbproject/genfiles.properties', 'nbproject/project.properties',
                   'nbproject/project.xml', 'src/Submission.java', 'test/SubmissionTest.java', 'build.xml']

    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      input_files.each do |name|
        zipfile.add(name, "./submission_generation/tmp/Submission_#{id}/#{file}/" + name)
      end
    end
  end

  def in_progress?
    %i[saved testing_stub testing_model_solution].include?(status)
  end
end
