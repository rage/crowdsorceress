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
    header = 'Errors in the tests: '

    messages = test_output['testResults'].each_with_object(String.new) do |test, string|
      unless test['successful']
        test_name = test['name'].split(' ').last
        string << "#{test_name}<linechange>#{parsed_test_error_message(test['message'])}"
      end
    end

    error = { header: header, messages: [{ message: messages }] }
    @exercise.error_messages.push error
  end

  def parsed_test_error_message(message)
    if message.include? 'expected'
      message.gsub('expected', '<linechange>- expected').concat('<linechange><linechange>')
    else
      message.concat('<linechange><linechange>')
    end
  end

  def compile_errors(test_output, package_type)
    return unless test_output['status'] == 'COMPILE_FAILED'
    header = package_type == 'TEMPLATE' ? 'The code template did no compile: ' : 'The model solution did not compile: '
    messages = compile_error_message_lines(test_output, header)
    error = { header: header, messages: messages }
    @exercise.error_messages.push error
  end

  def compile_error_message_lines(test_output, header)
    error_message = test_output['logs']['stdout'].pack('c*').force_encoding('utf-8')
    error_message = if error_message.include?('do-compile-test')
                      error_message.slice(/(?<=do-compile-test:\n)(.*?\n)*(.*$)/)
                    else
                      error_message.slice(/(?<=do-compile:\n)(.*?\n)*(.*$)/)
                    end

    modify_compile_error_messages(error_message.split(/\n/), header)
  end

  def modify_compile_error_messages(message_lines, header)
    modified_messages = []
    i = 0
    while i < message_lines.size
      if message_lines[i].include? 'SubmissionTest'
        beginning = 'Error in the test code'
      elsif message_lines[i].include? 'Submission'
        beginning = 'Error in the source code'
      else
        i += 1
        next
      end

      modified_messages.push modified_message(message_lines, i, beginning, header)

      i += 3
    end
    modified_messages
  end

  def modified_message(message_lines, index, beginning, header)
    if message_lines[index].include? 'location'
      then { message: '' }
    else
      errored_line_number = get_actual_errored_line(message_lines[index].slice(/\d+/), header)
      error = message_lines[index].slice(/(error:)(.*$)/).chomp
      errored_line = message_lines[index + 1].sub('[javac]', '').chomp
      error_mark_line = message_lines[index + 2].sub('[javac]', '').chomp
      marked_char = error_mark_line.index('^') - 5

      { message: "#{beginning} on the line #{errored_line_number}: #{error}\n#{errored_line}\n#{error_mark_line}\n",
        line: errored_line_number, char: marked_char } # TODO: remove this properly
    end
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
    @exercise.sandbox_results[:message] += if passed then 'Everything ok.'
                                           elsif compiled then 'All the tests did not pass.'
                                           else 'The code did not compile.'
                                           end
  end

  def template_message(compiled)
    @exercise.sandbox_results[:message] += ' Results for the code template: '
    @exercise.sandbox_results[:template_results_received] = true
    @exercise.sandbox_results[:message] += if compiled then 'Everything OK.'
                                           else 'The code did not compile.'
                                           end
  end

  def solution_lines
    lines = []
    counter = 1
    solution = false

    @exercise.code.split("\n").each do |line|
      if line.include?('// END SOLUTION')
        solution = false
        next
      end
      lines.push counter if solution
      if line.include?('// BEGIN SOLUTION')
        solution = true
        next
      end
      counter += 1
    end

    lines
  end

  def get_actual_errored_line(errored_line, header)
    errored_line_number = errored_line.to_i
    if header.include? 'The code template'
      solution_lines.each do |line_number|
        errored_line_number += 1 if line_number < errored_line_number
      end
    end
    errored_line_number.to_s
  end
end
