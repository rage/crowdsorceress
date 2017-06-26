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
      filename = 'Stub/src/Stub.java'
      generator = MainClassGenerator.new
      self.code = code.gsub(/\/\/\sBEGIN SOLUTION\n(.*?\n)*\/\/\sEND SOLUTION/, '')
      write_to_file(filename, generator, 'Stub')
    end

    if file_type == 'model_solution_file'
      filename = 'ModelSolution/src/ModelSolution.java'
      generator = MainClassGenerator.new
      self.code = self_code
      write_to_file(filename, generator, 'ModelSolution')
    end

    if file_type == 'testfile'
      filename = 'ModelSolution/test/ModelSolutionTest.java'
      generator = TestGenerator.new
      self.code = self_code
      write_to_file(filename, generator, 'ModelSolution')
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

  def handle_results(sandbox_status, passed, compiled, token)
    generate_message(sandbox_status, passed, compiled, token)

    # Status will be 'finished' if both stub results and model solution results are finished in sandbox
    if sandbox_results[:status] == '' || sandbox_results[:status] == 'finished'
      sandbox_results[:status] = sandbox_status
    end

    # Model solution is passed if test results are passed
    sandbox_results[:passed] = false unless passed

    # Update exercises standbox_results
    save!

    if sandbox_results[:model_results_received] && sandbox_results[:stub_results_received]
    then send_results_to_frontend(sandbox_results[:status], 1, sandbox_results[:passed])
    else send_results_to_frontend('in progress', 0.8, false)
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
    if sandbox_status == 'finished' && passed then sandbox_results[:message] += 'Kaikki OK.'
    elsif sandbox_status == 'finished' && compiled then sandbox_results[:message] += 'Testit eivät menneet läpi.'
    else
      sandbox_results[:message] += 'Koodi ei kääntynyt.'
      error_messages.push 'Compile failed'
    end

    save!
  end

  def send_results_to_frontend(status, progress, passed)
    results = { 'status' => status, 'message' => sandbox_results[:message], 'progress' => progress,
                'result' => { 'OK' => passed, 'error' => error_messages } }

    SubmissionStatusChannel.broadcast_to('SubmissionStatus', JSON[results])
  end
end
