class TestGenerator
  # def initialize(exercise_type)
  #   @exercise_type = exercise_type
  # end

  def generate(exercise)
    type = exercise.assignment.exercise_type.name
    return string_to_string(exercise) if type == 'string_string'
  end

  def string_to_string(exercise)
    io = exercise.testIO
    tests = ''
    counter = 1

    io.each do |key|
      input = key['input']
      output = key['output']

      tests += <<-eos
  @Test
  public void test#{counter}() {
    toimii(#{input}, #{output});
  }

eos
      counter += 1
    end

    test_template = <<-eos
import static org.junit.Assert.assertEquals;
import org.junit.Test;

public class StringInputStringOutputTest {

#{tests}
  private void toimii(String input, String output) {
    assertEquals(output, TulostusKolmesti.tulosta(input));
  }
}
eos
    test_template
  end
end
