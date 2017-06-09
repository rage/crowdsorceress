class TestGenerator
  def generate(exercise)
    type = exercise.assignment.exercise_type.name
    return string_to_string(exercise) if type == 'string_string'
    return int_to_int(exercise) if type == 'int_int'
  end

  def string_to_string(exercise)
    io = exercise.testIO
    tests = ''
    counter = 1

    io.each do |i|
      input = i['input']
      output = i['output']

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
  end

  def int_to_int(exercise)
    io = exercise.testIO
    tests = ''
    counter = 1

    io.each do |i|
      input = i['input']
      output = i['output']

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

public class IntInputIntOutputTest {

#{tests}
  private void toimii(int input, int output) {
    assertEquals(output, Kertolasku.korotaPotenssiinKaksi(input));
  }
}
    eos
  end
end
