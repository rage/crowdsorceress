# frozen_string_literal: true

class TestGenerator
  TESTS = <<-eos
  @Test
  public void test%<counter>s() {
    toimii(%<input>s, %<output>s);
  }

  eos

  TEST_TEMPLATE = <<~eos
    import fi.helsinki.cs.tmc.edutestutils.MockStdio;
    import fi.helsinki.cs.tmc.edutestutils.Points;
    import fi.helsinki.cs.tmc.edutestutils.ReflectionUtils;
    import org.junit.Rule;
    import org.junit.Test;
    import static org.junit.Assert.assertEquals;

    @Points("01-11")
    public class %<class_name>sTest {

    %<mock_stdio_init>s

      public %<class_name>sTest() {

      }

    %<tests>s
      private void toimii(%<input_type>s input, %<output_type>s output) {
        %<test_code>s
      }
    }
  eos

  def generate(exercise, class_name)
    type = exercise.assignment.exercise_type.name
    if type == 'stdin_stdout'
      stdin_to_stdout(exercise, class_name)
    elsif %w[string_string int_int].include? type
      input_to_output(exercise, type, class_name)
    elsif type == 'string_stdout'
      string_to_stdout(exercise, class_name)
    end
  end

  def stdin_to_stdout(exercise, class_name)
    input_type = 'String'
    output_type = 'String'

    mock_stdio_init = <<~eos
      @Rule
      public MockStdio io = new MockStdio();
    eos

    test_code = <<~eos
      ReflectionUtils.newInstanceOfClass(#{class_name}.class);
      io.setSysIn(input);
      #{class_name}.main(new String[0]);

      String out = io.getSysOut();

      assertEquals(output, out);
    eos

    template_params = { input_type: input_type, output_type: output_type, class_name: class_name, test_code: test_code,
                        mock_stdio_init: mock_stdio_init }

    generate_string(exercise, template_params)
  end

  def string_to_stdout(exercise, class_name)
    input_type = 'String'
    output_type = 'String'

    mock_stdio_init = <<~eos
      @Rule
      public MockStdio io = new MockStdio();
    eos

    test_code = <<~eos
      #{class_name}.metodi(input);

      String out = io.getSysOut();
      assertEquals(output, out);
    eos

    template_params = { input_type: input_type, output_type: output_type, class_name: class_name, test_code: test_code,
                        mock_stdio_init: mock_stdio_init }

    generate_string(exercise, template_params)
  end

  def input_to_output(exercise, type, class_name) # input and output both exist
    if type == 'string_string'
      input_type = 'String'
      output_type = 'String'
    elsif type == 'int_int'
      input_type = 'int'
      output_type = 'int'
    end

    test_code = "assertEquals(output, #{class_name}.metodi(input));"

    template_params = { input_type: input_type, output_type: output_type, class_name: class_name, test_code: test_code, mock_stdio_init: '' }

    generate_string(exercise, template_params)
  end

  private

  def generate_string(exercise, template_params)
    tests = generate_tests(exercise, template_params[:input_type], template_params[:output_type])

    format(TEST_TEMPLATE, tests: tests, input_type: template_params[:input_type],
                          output_type: template_params[:output_type], class_name: template_params[:class_name],
                          mock_stdio_init: template_params[:mock_stdio_init], imports: template_params[:imports], test_code: template_params[:test_code])
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
