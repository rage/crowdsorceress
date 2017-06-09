class TestGenerator
  TESTS = <<-eos.freeze
  @Test
  public void test%<counter>s() {
    toimii(%<input>s, %<output>s);
  }

  eos

  TEST_TEMPLATE = <<-eos.freeze
import static org.junit.Assert.assertEquals;
import org.junit.Test;

public class %<class_name>sTest {

%<tests>s
  private void toimii(%<input_type>s input, %<output_type>s output) {
    assertEquals(output, %<class_name>s.%<method_name>s(input));
  }
}
  eos

  def generate(exercise)
    type = exercise.assignment.exercise_type.name
    input_to_output(exercise, type)
  end

  def input_to_output(exercise, type) # input and output both exist
    # TODO: get class_name and method_name
    class_name = 'Class'
    method_name = 'method'

    if type == 'string_string'
      input_type = 'String'
      output_type = 'String'
    end

    if type == 'int_int'
      input_type = 'int'
      output_type = 'int'
    end

    generate_string(exercise, input_type, output_type, class_name, method_name)
  end

  def generate_string(exercise, input_type, output_type, class_name, method_name)
    tests = ''
    counter = 1

    exercise.testIO.each do |i|
      input = i['input']
      output = i['output']
      tests += format(TESTS, counter: counter, input: input, output: output)
      counter += 1
    end

    format(TEST_TEMPLATE, class_name: class_name, tests: tests,
                          input_type: input_type, output_type: output_type, method_name: method_name)
  end
end
