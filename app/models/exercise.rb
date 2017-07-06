# frozen_string_literal: true

class Exercise < ApplicationRecord
  belongs_to :assignment
  belongs_to :user

  validates :description, presence: true
  validates :testIO, presence: true
  validates :code, presence: true

  serialize :sandbox_results, Hash

  enum status: %i[status_undefined saved testing_stub testing_model_solution finished error]

  def create_file(file_type)
    self_code = code

    if file_type == 'stubfile'
      self.code = code.gsub(%r{\/\/\sBEGIN SOLUTION\n(.*?\n)*\/\/\sEND SOLUTION}, '')
      write_to_file('Stub/src/Stub.java', MainClassGenerator.new, 'Stub')
    end

    if file_type == 'model_solution_file'
      self.code = self_code
      write_to_file('ModelSolution/src/ModelSolution.java', MainClassGenerator.new, 'ModelSolution')
    end

    if file_type == 'testfile'
      self.code = self_code
      write_to_file('ModelSolution/test/ModelSolutionTest.java', TestGenerator.new, 'ModelSolution')
    end

    self.code = self_code
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

    # Update exercises sandbox_results
    save!
  end

  def exercise_errors(test_output, token)
    test_results(test_output)
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
                                 elsif sandbox_status == 'finished' && compiled then 'Testit eivät menneet läpi.'
                                 else
                                   'Koodi ei kääntynyt.'
                                 end
  end

  def send_results_to_frontend(status, progress, passed)
    results = { 'status' => status, 'message' => sandbox_results[:message], 'progress' => progress,
                'result' => { 'OK' => passed, 'error' => error_messages } }

    SubmissionStatusChannel.broadcast_to("SubmissionStatus_user:_#{user_id}_exercise:_#{id}", JSON[results])

    status == 'finished' && passed ? finished! : error!
  end

  def in_progress?
    %i[saved testing_stub testing_model_solution].include?(status)
  end
end
