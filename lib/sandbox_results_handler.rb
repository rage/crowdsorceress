# frozen_string_literal: true

class SandboxResultsHandler
  def initialize(exercise)
    @exercise = exercise
  end

  def handle(test_output, package_type)
    test_results(test_output) if package_type == 'MODEL'
    compile_errors(test_output, package_type)

    generate_data_for_frontend(test_output, package_type)
  end

  def generate_data_for_frontend(test_output, package_type)
    generate_message(test_output['status'] == 'PASSED', test_output['status'] != 'COMPILE_FAILED', package_type)

    # Exercise is passed if test results are passed
    @exercise.sandbox_results[:passed] = test_output['status'] == 'PASSED'

    # Update exercise's sandbox_results
    @exercise.save!
  end

  def test_results(test_output)
    # Push test results into exercise's error messages
    return if test_output['testResults'].empty? || test_output['status'] == 'PASSED'
    header = 'Virheet testeissä: '
    messages = ''
    test_output['testResults'].each_with_object('') do |test|
      messages += "#{test['message']}<linechange>"
    end
    error = { header: header, messages: messages }
    @exercise.error_messages.push error
  end

  def compile_errors(test_output, package_type)
    return unless test_output['status'] == 'COMPILE_FAILED'
    header = package_type == 'TEMPLATE' ? 'Tehtäväpohja ei kääntynyt: ' : 'Malliratkaisu ei kääntynyt: '
    messages = error_message_lines(test_output).join('<linechange>')
    error = { header: header, messages: messages }
    @exercise.error_messages.push error
  end

  def error_message_lines(test_output)
    test_output['logs']['stdout'].pack('c*').force_encoding('utf-8').slice(/(?<=do-compile:\n)(.*?\n)*(.*$)/).split(/\n/)
  end

  # Generate message that will be sent to frontend
  def generate_message(passed, compiled, package_type)
    if package_type == 'MODEL'
      model_message(passed, compiled)
    elsif package_type == 'TEMPLATE'
      template_message(compiled)
    end
  end

  def model_message(passed, compiled)
    @exercise.sandbox_results[:message] += ' Malliratkaisun tulokset: '
    @exercise.sandbox_results[:model_results_received] = true
    @exercise.sandbox_results[:message] += if passed then 'Kaikki OK.'
                                           elsif compiled then 'Testit eivät menneet läpi.'
                                           else 'Koodi ei kääntynyt.'
                                           end
  end

  def template_message(compiled)
    @exercise.sandbox_results[:message] += ' Tehtäväpohjan tulokset: '
    @exercise.sandbox_results[:template_results_received] = true
    @exercise.sandbox_results[:message] += if compiled then 'Kaikki OK.'
                                           else 'Koodi ei kääntynyt.'
                                           end
  end
end
