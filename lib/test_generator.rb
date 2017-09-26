# frozen_string_literal: true

require 'test_templates'

POSITIVE_TESTS =
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
    prettify_io(exercise, template_params[:input_type], template_params[:output_type])

    tests = generate_tests(exercise)

    format(exercise.assignment.exercise_type.test_template, tests: tests, input_type: template_params[:input_type],
                                                            output_type: template_params[:output_type], mock_stdio_init: MOCK_STDIO_INIT)
  end

  def generate_tests(exercise)
    tests = ''
    counter = 1

    exercise.testIO.each do |io|
      if io['type'] == 'positive' # TODO: decide how to name testio types
        tests += format(POSITIVE_TESTS, counter: counter, input: io['input'], output: io['output'])
        counter += 1
      elsif io['type'] == 'negative' # TODO: see previous
        tests += format(NEGATIVE_TESTS, counter: counter, input: io['input'], output: io['output'])
        counter += 1
      end
    end

    tests
  end

  def prettify_io(exercise, input_type, output_type)
    new_io = []

    exercise.testIO.each do |io|
      input = input_type == 'String' ? prettify_string(io['input']) : io['input']
      output = output_type == 'String' ? prettify_string(io['output']) : io['output']
      new_io.push(input: input, output: output, type: io['type'])
    end

    exercise.testIO = new_io
  end

  def prettify_string(str)
    prettified = str.gsub(/\A"|"\Z/, '')
    "\"#{prettified}\""
  end
end
