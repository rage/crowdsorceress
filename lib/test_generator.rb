# frozen_string_literal: true

require 'test_templates'

class TestGenerator
  class ExerciseTypeNotSupportedError < StandardError; end

  def initialize
    @test_templates = TestTemplates.new
  end

  def generate(exercise)
    type = exercise.assignment.exercise_type.name
    if type == 'string_stdin_string_stdout'
      string_stdin_to_string_stdout(exercise)
    elsif %w[string_string int_int].include? type
      input_to_output(exercise, type)
    elsif type == 'string_stdout'
      string_to_stdout(exercise)
    elsif type == 'int_stdin_int_stdout'
      int_stdin_to_int_stdout(exercise)
    elsif type == 'string_stdin_int_stdout'
      string_stdin_to_int_stdout(exercise)
    elsif type == 'int_stdin_string_stdout'
      int_stdin_to_string_stdout(exercise)
    else
      exercise_type_not_supported(exercise)
    end
  end

  def exercise_type_not_supported(exercise)
    exercise.error_messages.push(header: 'Järjestelmä ei tue tällaista tehtävätyyppiä', messages: '')
    exercise.error!
    MessageBroadcasterJob.perform_now(exercise)

    raise ExerciseTypeNotSupportedError
  end

  def string_stdin_to_string_stdout(exercise)
    input_type = 'String'
    output_type = 'String'

    template_params = { input_type: input_type, output_type: output_type, test_code: @test_templates.string_stdin_string_stdout_test_code,
                        mock_stdio_init: @test_templates.mock_stdio_init }

    generate_string(exercise, template_params)
  end

  def string_to_stdout(exercise)
    input_type = 'String'
    output_type = 'String'

    template_params = { input_type: input_type, output_type: output_type, test_code: @test_templates.string_stdout_test_code,
                        mock_stdio_init: @test_templates.mock_stdio_init }

    generate_string(exercise, template_params)
  end

  def int_stdin_to_int_stdout(exercise)
    input_type = 'int'
    output_type = 'int'

    template_params = { input_type: input_type, output_type: output_type, test_code: @test_templates.int_stdin_int_stdout_test_code,
                        mock_stdio_init: @test_templates.mock_stdio_init }

    generate_string(exercise, template_params)
  end

  def string_stdin_to_int_stdout(exercise)
    input_type = 'String'
    output_type = 'int'

    template_params = { input_type: input_type, output_type: output_type, test_code: @test_templates.string_stdin_int_stdout_test_code,
                        mock_stdio_init: @test_templates.mock_stdio_init }

    generate_string(exercise, template_params)
  end

  def int_stdin_to_string_stdout(exercise)
    input_type = 'int'
    output_type = 'String'

    template_params = { input_type: input_type, output_type: output_type, test_code: @test_templates.int_stdin_string_stdout_test_code,
                        mock_stdio_init: @test_templates.mock_stdio_init }

    generate_string(exercise, template_params)
  end

  def input_to_output(exercise, type) # input and output both exist
    if type == 'string_string'
      input_type = 'String'
      output_type = 'String'
    elsif type == 'int_int'
      input_type = 'int'
      output_type = 'int'
    end

    test_code = 'assertEquals(output, Submission.metodi(input));'

    template_params = { input_type: input_type, output_type: output_type, test_code: test_code, mock_stdio_init: '' }

    generate_string(exercise, template_params)
  end

  private

  def generate_string(exercise, template_params)
    tests = generate_tests(exercise, template_params[:input_type], template_params[:output_type])

    format(@test_templates.test_template, tests: tests, input_type: template_params[:input_type],
                                          output_type: template_params[:output_type], mock_stdio_init: template_params[:mock_stdio_init],
                                          imports: template_params[:imports], test_code: template_params[:test_code])
  end

  def generate_tests(exercise, input_type, output_type)
    tests = ''
    counter = 1

    exercise.testIO.each do |i|
      input = input_type == 'String' ? prettify_string(i['input']) : i['input']
      output = output_type == 'String' ? prettify_string(i['output']) : i['output']

      tests += format(@test_templates.tests, counter: counter, input: input, output: output)
      counter += 1
    end

    tests
  end

  def prettify_string(str)
    prettified = str.gsub(/\A"|"\Z/, '')
    "\"#{prettified}\""
  end
end
