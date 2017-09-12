# frozen_string_literal: true

require 'test_templates'

TESTS =
  <<-eos
  @Test
  public void test%<counter>s() {
  toimii(%<input>s, %<output>s);
  }

  eos
  MOCK_STDIO_INIT=
  <<-eos
  @Rule
  public MockStdio io = new MockStdio();

  eos

class TestGenerator
  class ExerciseTypeNotSupportedError < StandardError; end

  def initialize
    @test_templates = TestTemplates.new
  end

  def generate(exercise)
    exercise_type = exercise.assignment.exercise_type

    template_params = { input_type: exercise_type.input_type, output_type: exercise_type.output_type,
                        mock_stdio_init: mock_stdio_init }

    generate_string(exercise, template_params)
  end

  private

  def generate_string(exercise, template_params)
    tests = generate_tests(exercise, template_params[:input_type], template_params[:output_type])

    format(exercise.assignment.exercise_type.test_template, tests: tests, input_type: template_params[:input_type],
           output_type: template_params[:output_type], mock_stdio_init: mock_stdio_init)
  end

  def generate_tests(exercise, input_type, output_type)
    tests = ''
    counter = 1

    exercise.testIO.each do |i|
      input = input_type == 'String' ? prettify_string(i['input']) : i['input']
      output = output_type == 'String' ? prettify_string(i['output']) : i['output']

      tests += format(TESTS, counter: counter, input: input, output: output)
      counter += 1
    end

    tests
  end

  def prettify_string(str)
    prettified = str.gsub(/\A"|"\Z/, '')
    "\"#{prettified}\""
  end
end
