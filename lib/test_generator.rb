# frozen_string_literal: true

# require 'test_templates'

TESTS =
  <<~eos
    @Test
        public void test%<counter>s() {
            toimii(%<input>s, %<output>s);
        }

  eos

MOCK_STDIO_INIT =
  <<~eos
    @Rule
        public MockStdio io = new MockStdio();

  eos

PYTHON_TEST =
  <<~eos
    def test_%<counter>s(self, mock_stdout):
        with patch('builtins.input', side_effect=[%<input>s]):
          main()
          actual = mock_stdout.getvalue()
        expected = %<output>s
        self.assertIn(expected, actual)
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

    tests = if exercise.assignment.exercise_type.testing_type == 'io_and_code' || exercise.assignment.exercise_type.testing_type == 'tests_for_set_up_code'
              exercise.unit_tests.map { |test| test['test_code'] }.join("\n\n")
            else
              generate_tests(exercise)
            end

    test_template = exercise.assignment.exercise_type.test_template

    format(test_template, tests: tests, input_type: template_params[:input_type],
                          output_type: template_params[:output_type], mock_stdio_init: MOCK_STDIO_INIT)
  end

  def generate_tests(exercise)
    tests = ''
    counter = 1

    test_method_template = exercise.assignment.course.language == 'Java' ? TESTS : PYTHON_TEST

    exercise.testIO.each do |io|
      tests += format(test_method_template, counter: counter, input: io['input'], output: io['output'])
      counter += 1
    end

    tests
  end

  def prettify_io(exercise, input_type, output_type)
    new_io = []

    exercise.testIO.each do |io|
      input = input_type == 'String' ? prettify_string(io['input']) : io['input']
      output = output_type == 'String' ? prettify_string(io['output']) : io['output']
      new_io.push(input: input, output: output)
    end

    exercise.testIO = new_io
  end

  def prettify_string(str)
    prettified = str.gsub(/\A"|"\Z/, '')
    "\"#{prettified}\""
  end
end
