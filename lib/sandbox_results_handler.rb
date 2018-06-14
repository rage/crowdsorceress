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
    header = package_type == 'TEMPLATE' ? 'Tehtäväpohja ei kääntynyt: ' : 'Malliratkaisu ei kääntynyt: '
    messages = compile_error_message_lines(test_output)
    error = { header: header, messages: messages }
    @exercise.error_messages.push error
  end

  def compile_error_message_lines(test_output)
    error_message = test_output['logs']['stdout'].pack('c*').force_encoding('utf-8')
    error_message = if error_message.include?('do-compile-test')
                      error_message.slice(/(?<=do-compile-test:\n)(.*?\n)*(.*$)/)
                    else
                      error_message.slice(/(?<=do-compile:\n)(.*?\n)*(.*$)/)
                    end

    modify_compile_error_messages(error_message.split(/\n/))
  end

  def modify_compile_error_messages(message_lines)
    modified_messages = []
    i = 0
    while i < message_lines.size
      if message_lines[i].include? 'SubmissionTest'
        beginning = 'Virhe testikoodissa'
      elsif message_lines[i].include? 'Submission'
        beginning = 'Virhe lähdekoodissa'
      else
        i += 1
        next
      end

      modified_messages.push modified_message(message_lines, i, beginning)

      i += 3
    end
    modified_messages
  end

  def modified_message(message_lines, i, beginning)
    if message_lines[i].include? 'location'
      then { message: '' }
    else
      errored_line_number = message_lines[i].slice(/\d+/)
      error = message_lines[i].slice(/(error:)(.*$)/).chomp
      errored_line = message_lines[i + 1].sub('[javac]', '').chomp
      error_mark_line = message_lines[i + 2].sub('[javac]', '').chomp
      marked_char = error_mark_line.index('^') - 5

      { message: "#{beginning} rivillä #{errored_line_number} merkissä järjestysnumeroltaan #{marked_char}. vasemmalta yksi merkki kerrallaan laskettuna: #{error}\n#{errored_line}\n#{error_mark_line}\n",
        line: errored_line_number, char: marked_char }
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
