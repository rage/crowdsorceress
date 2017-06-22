# frozen_string_literal: true

class TestGenerator
  TESTS = <<-eos
  @Test
  public void test%<counter>s() {
    toimii(%<input>s, %<output>s);
  }

  eos

  TEST_TEMPLATE = <<~eos
    import fi.helsinki.cs.tmc.edutestutils.Points;
    import static org.junit.Assert.assertEquals;
    import org.junit.Test;

    @Points("01-11")
    public class %<class_name>sTest {

      public %<class_name>sTest() {

      }

    %<tests>s
      private void toimii(%<input_type>s input, %<output_type>s output) {
        assertEquals(output, %<class_name>s.metodi(input));
      }
    }
  eos

  def generate(exercise, class_name)
    type = exercise.assignment.exercise_type.name
    input_to_output(exercise, type, class_name)
  end

  def input_to_output(exercise, type, class_name) # input and output both exist
    if type == 'string_string'
      input_type = 'String'
      output_type = 'String'
    end

    if type == 'int_int'
      input_type = 'int'
      output_type = 'int'
    end

    generate_string(exercise, input_type, output_type, class_name)
  end

  def generate_string(exercise, input_type, output_type, class_name)
    tests = ''
    counter = 1

    exercise.testIO.each do |i|
      input = input_type == 'String' ? prettify_string(i['input']) : i['input']
      output = output_type == 'String' ? prettify_string(i['output']) : i['output']

      tests += format(TESTS, counter: counter, input: input, output: output)
      counter += 1
    end

    format(TEST_TEMPLATE, tests: tests,
                          input_type: input_type, output_type: output_type, class_name: class_name)
  end

  def prettify_string(str)
    prettified = str.gsub(/\A"|"\Z/, '')
    "\"#{prettified}\""
  end
end
