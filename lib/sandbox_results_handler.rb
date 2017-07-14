# frozen_string_literal: true

class SandboxResultsHandler
  def initialize(exercise)
    @exercise = exercise
  end

  def handle(sandbox_status, test_output, package_type)
    test_results(test_output) if package_type == 'MODEL'
    compile_errors(test_output, package_type)

    generate_data_for_frontend(sandbox_status, test_output, package_type)
  end

  def generate_data_for_frontend(sandbox_status, test_output, package_type)
    generate_message(sandbox_status, test_output['status'] == 'PASSED', test_output['status'] != 'COMPILE_FAILED', package_type)

    set_status_and_passed_state(sandbox_status, test_output)

    # Update exercise's sandbox_results
    @exercise.save!
  end

  def set_status_and_passed_state(sandbox_status, test_output)
    # Status will be 'finished' if both stub results and model solution results are finished in sandbox
    if @exercise.sandbox_results[:status] == '' || @exercise.sandbox_results[:status] == 'finished'
      @exercise.sandbox_results[:status] = sandbox_status
    end

    # Model solution is passed if test results are passed
    @exercise.sandbox_results[:passed] = true unless test_output['status'] != 'PASSED'
  end

  def test_results(test_output)
    # Push test results into exercise's error messages
    return if test_output['testResults'].empty? || test_output['testResults'].first['successful']
    @exercise.error_messages.push 'Virheet testeissä: '
    test_output['testResults'].each do |e|
      @exercise.error_messages.push e['message']
    end
  end

  def compile_errors(test_output, package_type)
    return unless test_output['status'] == 'COMPILE_FAILED'

    package_type == 'STUB' ? (@exercise.error_messages.push 'Tehtäväpohja ei kääntynyt: ') : (@exercise.error_messages.push 'Malliratkaisu ei kääntynyt: ')

    error_message_lines(test_output).each do |line|
      @exercise.error_messages.push line
    end
  end

  def error_message_lines(test_output)
    test_output['logs']['stdout'].pack('c*').slice(/(?<=do-compile:\n)(.*?\n)*(.*$)/).split(/\n/)
  end

  # Generate message that will be sent to frontend
  def generate_message(sandbox_status, passed, compiled, package_type)
    if package_type == 'MODEL'
      model_message(sandbox_status, passed, compiled)
    elsif package_type == 'STUB'
      stub_message(sandbox_status, compiled)
    end
  end

  def model_message(sandbox_status, passed, compiled)
    @exercise.sandbox_results[:message] += ' Malliratkaisun tulokset: '
    @exercise.sandbox_results[:model_results_received] = true
    @exercise.sandbox_results[:message] += if sandbox_status == 'finished' && passed then 'Kaikki OK.'
                                           elsif sandbox_status == 'finished' && compiled then 'Testit eivät menneet läpi.'
                                           else 'Koodi ei kääntynyt.'
                                           end
  end

  def stub_message(sandbox_status, compiled)
    @exercise.sandbox_results[:message] += ' Tehtäväpohjan tulokset: '
    @exercise.sandbox_results[:stub_results_received] = true
    @exercise.sandbox_results[:message] += if sandbox_status == 'finished' && compiled then 'Kaikki OK.'
                                           else 'Koodi ei kääntynyt.'
                                           end
  end
end
