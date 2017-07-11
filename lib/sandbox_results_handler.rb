# frozen_string_literal: true

class SandboxResultsHandler
  def initialize(exercise)
    @exercise = exercise
  end

  def handle(sandbox_status, test_output, token)
    test_results(test_output) if token == 'MODEL'
    compile_errors(test_output, token)

    generate_data_for_frontend(sandbox_status, test_output, token)
  end

  def generate_data_for_frontend(sandbox_status, test_output, token)
    generate_message(sandbox_status, test_output['status'] == 'PASSED', test_output['status'] != 'COMPILE_FAILED', token)

    # Status will be 'finished' if both stub results and model solution results are finished in sandbox
    if @exercise.sandbox_results[:status] == '' || @exercise.sandbox_results[:status] == 'finished'
      @exercise.sandbox_results[:status] = sandbox_status
    end

    # Model solution is passed if test results are passed
    @exercise.sandbox_results[:passed] = true unless test_output['status'] != 'PASSED'

    # Update exercise's sandbox_results
    @exercise.save!
  end

  def test_results(test_output)
    # Push test results into exercise's error messages
    return if test_output['testResults'].empty? || test_output['testResults'].first['successful']
    @exercise.error_messages.push 'Virheet testeissä: '
    test_output['testResults'].each do |e|
      @exercise.error_messages.push e['message']
    end
  end

  def compile_errors(test_output, token)
    # Push compile errors into exercise's error messages
    return unless test_output['status'] == 'COMPILE_FAILED'

    token == 'STUB' ? (@exercise.error_messages.push 'Tehtäväpohja ei kääntynyt: ') : (@exercise.error_messages.push 'Malliratkaisu ei kääntynyt: ')

    error_message_lines = test_output['logs']['stdout'].pack('c*').slice(/(?<=do-compile:\n)(.*?\n)*(.*$)/).split(/\n/)
    error_message_lines.each do |line|
      @exercise.error_messages.push line
    end
  end

  # Generate message that will be sent to frontend
  def generate_message(sandbox_status, passed, compiled, token)
    if token == 'MODEL'
      @exercise.sandbox_results[:message] += ' Malliratkaisun tulokset: '
      @exercise.sandbox_results[:model_results_received] = true
      @exercise.sandbox_results[:message] += if sandbox_status == 'finished' && passed then 'Kaikki OK.'
                                             elsif sandbox_status == 'finished' && compiled then 'Testit eivät menneet läpi.'
                                             else 'Koodi ei kääntynyt.'
                                             end
    elsif token == 'STUB'
      @exercise.sandbox_results[:message] += ' Tehtäväpohjan tulokset: '
      @exercise.sandbox_results[:stub_results_received] = true
      @exercise.sandbox_results[:message] += if sandbox_status == 'finished' && compiled then 'Kaikki OK.'
                                             else 'Koodi ei kääntynyt.'
                                             end
    end
  end
end