# frozen_string_literal: true

require 'test_templates'

TESTS =
  <<~eos
    @Test
        public void test%<counter>s() {
            testPositiveCase(%<input>s, %<output>s);
        }

  eos

NEGATIVE_TESTS =
  <<~eos
    @Test
        public void test%<counter>s() {
            testNegativeCase(%<input>s, %<output>s);
        }

eos

MOCK_STDIO_INIT =
  <<~eos
    @Rule
        public MockStdio io = new MockStdio();

  eos

class TestGenerator
  class TestTemplateDoesNotExistError < StandardError; end

  def generate(exercise)
    exercise_type = exercise.assignment.exercise_type
    raise TestTemplateDoesNotExistError if exercise_type.test_template.blank?

    template_params = { input_type: exercise_type.input_type, output_type: exercise_type.output_type,
                        mock_stdio_init: MOCK_STDIO_INIT }

    generate_string(exercise, template_params)
  end

  private

  def generate_string(exercise, template_params)
    exercise.testIO = prettify_io(exercise.testIO, template_params[:input_type], template_params[:output_type])
    unless exercise.negTestIO.nil?
      exercise.negTestIO = prettify_io(exercise.negTestIO, template_params[:input_type], template_params[:output_type])
    end

    tests = generate_tests(exercise)

    format(exercise.assignment.exercise_type.test_template, tests: tests, input_type: template_params[:input_type],
                                                            output_type: template_params[:output_type], mock_stdio_init: MOCK_STDIO_INIT)
  end

  def generate_tests(exercise)
    tests = ''
    counter = 1

    exercise.testIO.each do |i|
      tests += format(TESTS, counter: counter, input: i['input'], output: i['output'])
      counter += 1
    end

    exercise.negTestIO&.each do |i|
      tests += format(NEGATIVE_TESTS, counter: counter, input: i['input'], output: i['output'])
      counter += 1
    end

    tests
  end

  def prettify_io(test_io, input_type, output_type)
    new_io = []

    test_io.each do |i|
      input = input_type == 'String' ? prettify_string(i['input']) : i['input']
      output = output_type == 'String' ? prettify_string(i['output']) : i['output']
      new_io.push(input: input, output: output)
    end
    
    new_io
  end

  def prettify_string(str)
    prettified = str.gsub(/\A"|"\Z/, '')
    "\"#{prettified}\""
  end
end
