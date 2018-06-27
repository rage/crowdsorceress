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
    header = 'Errors in tests: '

    messages = test_output['testResults'].each_with_object(String.new) do |test, string|
      string << "#{test['message']}<linechange>"
    end

    error = { header: header, messages: messages }
    @exercise.error_messages.push error
  end

  def compile_errors(test_output, package_type)
    return unless test_output['status'] == 'COMPILE_FAILED'
    header = package_type == 'TEMPLATE' ? 'The code template did not compile: ' : 'The model solution did not compile: '
    messages = error_message_lines(test_output).join('<linechange>')
    error = { header: header, messages: messages }
    @exercise.error_messages.push error
  end

  def error_message_lines(test_output)
    error_message = test_output['logs']['stdout'].pack('c*').force_encoding('utf-8')
    error_message = if error_message.include?('do-compile-test')
                      error_message.slice(/(?<=do-compile-test:\n)(.*?\n)*(.*$)/)
                    else
                      error_message.slice(/(?<=do-compile:\n)(.*?\n)*(.*$)/)
                    end

    error_message.split(/\n/)
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
    @exercise.sandbox_results[:message] += ' Results for the model solution: '
    @exercise.sandbox_results[:model_results_received] = true
    @exercise.sandbox_results[:message] += if passed then 'Everything is OK.'
                                           elsif compiled then 'Tests did not pass.'
                                           else 'Code did not compile.'
                                           end
  end

  def template_message(compiled)
    @exercise.sandbox_results[:message] += ' Results for the code template: '
    @exercise.sandbox_results[:template_results_received] = true
    @exercise.sandbox_results[:message] += if compiled then 'Everything is OK.'
                                           else 'Code did not compile.'
                                           end
  end
end
