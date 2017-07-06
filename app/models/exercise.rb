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
    # muisto: self.code = code.gsub(%r{\/\/\sBEGIN SOLUTION\n(.*?\n)*\/\/\sEND SOLUTION}, '')

    write_to_file('submission_generation/Submission/src/Submission.java', MainClassGenerator.new, 'Submission')
    write_to_file('submission_generation/Submission/test/SubmissionTest.java', TestGenerator.new, 'Submission')

    create_model_solution_and_stub
  end

  def create_model_solution_and_stub
    TMCLangs.prepare_solutions
    TMCLangs.prepare_stubs
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
    sandbox_results[:passed] = false unless test_output['status'] == 'PASSED'

    # Update exercise's sandbox_results
    save!
  end

  def exercise_errors(test_output, token)
    test_results(test_output) if token == 'MODEL_KISSA'
    compile_errors(test_output, token)
  end

  def test_results(test_output)
    # Push test results into exercise's error messages
    return if test_output['testResults'].empty?
    error_messages.push 'Virheet testeissä: '
    test_output['testResults'].each do |e|
      error_messages.push e['message']
    end
  end

  def compile_errors(test_output, token)
    # Push compile errors into exercise's error messages
    return unless test_output['status'] == 'COMPILE_FAILED'

    token == 'KISSA_STUB' ? (error_messages.push 'Tehtäväpohja ei kääntynyt: ') : (error_messages.push 'Malliratkaisu ei kääntynyt: ')

    error_message_lines = test_output['logs']['stdout'].pack('c*').slice(/(?<=do-compile:\n)(.*?\n)*(.*$)/).split(/\n/)
    error_message_lines.each do |line|
      error_messages.push line
    end
  end

  # Generate message that will be sent to frontend
  def generate_message(sandbox_status, passed, compiled, token)
    if token == 'KISSA_STUB'
      sandbox_results[:message] += ' Tehtäväpohjan tulokset: '
      sandbox_results[:stub_results_received] = true
    else
      sandbox_results[:message] += ' Malliratkaisun tulokset: '
      sandbox_results[:model_results_received] = true
    end
    sandbox_results[:message] += if sandbox_status == 'finished' && passed then 'Kaikki OK.'
                                 elsif sandbox_status == 'finished' && compiled && token == 'MODEL_KISSA' then 'Testit eivät menneet läpi.'
                                 else
                                   'Koodi ei kääntynyt.'
                                 end
  end

  def send_results_to_frontend(status, progress, passed)
    results = { 'status' => status, 'message' => sandbox_results[:message], 'progress' => progress,
                'result' => { 'OK' => passed, 'error' => error_messages } }

    SubmissionStatusChannel.broadcast_to("SubmissionStatus_user:_#{user_id}_exercise:_#{id}", JSON[results])

    status == 'finished' && passed ? finished! : error!

    # create_zip if finished?
  end

  # TODO: fix this method
  # def create_zip
  #   stub_zipfile_name = "./packages/Stub#{id}.zip"
  #   modelsolution_zipfile_name = "./packages/Submission#{id}.zip"
  #
  #   stub_input = ['lib/testrunner/tmc-junit-runner.jar', 'lib/edu-test-utils-0.4.2.jar', 'lib/junit-4.10.jar',
  #                 'nbproject/private/private.properties', 'nbproject/private/private.xml', 'nbproject/build-impl.xml',
  #                 'nbproject/genfiles.properties', 'nbproject/project.properties', 'nbproject/project.xml',
  #                 'src/Stub.java', 'test/StubTest.java', 'build.xml']
  #
  #   modelsolution_input = ['lib/testrunner/tmc-junit-runner.jar', 'lib/edu-test-utils-0.4.2.jar', 'lib/junit-4.10.jar',
  #                          'nbproject/private/private.properties', 'nbproject/private/private.xml', 'nbproject/build-impl.xml',
  #                          'nbproject/genfiles.properties', 'nbproject/project.properties', 'nbproject/project.xml',
  #                          'src/Submission.java', 'test/ModelSolutionTest.java', 'build.xml']
  #
  #   Zip::File.open(stub_zipfile_name, Zip::File::CREATE) do |zipfile|
  #     stub_input.each do |name|
  #       #TODO change path
  #       zipfile.add(name, './langs-tmp/stub/' + name)
  #     end
  #   end
  #
  #   Zip::File.open(modelsolution_zipfile_name, Zip::File::CREATE) do |zipfile|
  #     modelsolution_input.each do |name|
  #       zipfile.add(name, './Submission/' + name)
  #     end
  #   end
  # end
end
