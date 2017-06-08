class TestGenerator
  # def initialize(exercise_type)
  #   @exercise_type = exercise_type
  # end

  def generate(exercise_type, io, code)
    # raise 'Unsupported exercise type.' unless @exercise_type == :string_string
    return string_to_string(io, code) if exercise_type == :string_string
  end

  def string_to_string(io, _code)
    tests = ''

    io.each do |key, value|
      input = value[:input]
      output = value[:output]

      tests += <<-eos
  @Test
  public void test#{key}() {
    toimii(#{input}, #{output});
  }

eos
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

    puts test_template
    test_template
  end
end
