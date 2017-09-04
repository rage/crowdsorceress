# frozen_string_literal: true

class TestTemplates
  def tests
    <<-eos
  @Test
  public void test%<counter>s() {
    toimii(%<input>s, %<output>s);
  }

    eos
  end

  def test_template
    <<~eos
      import fi.helsinki.cs.tmc.edutestutils.MockStdio;
      import fi.helsinki.cs.tmc.edutestutils.Points;
      import fi.helsinki.cs.tmc.edutestutils.ReflectionUtils;
      import org.junit.Rule;
      import org.junit.Test;
      import static org.junit.Assert.assertEquals;

      @Points("01-11")
      public class SubmissionTest {

      %<mock_stdio_init>s

        public SubmissionTest() {

        }

      %<tests>s
        private void toimii(%<input_type>s input, %<output_type>s output) {
          %<test_code>s
        }
      }
    eos
  end

  def string_stdin_string_stdout_test_code
    <<~eos
      ReflectionUtils.newInstanceOfClass(Submission.class);
      io.setSysIn(input);
      Submission.main(new String[0]);

      String out = io.getSysOut();

      assertEquals(output, out);
    eos
  end

  def mock_stdio_init
    <<~eos
      @Rule
      public MockStdio io = new MockStdio();
    eos
  end

  def string_stdout_test_code
    <<~eos
      Submission.metodi(input);

      String out = io.getSysOut();
      assertEquals(output, out);
    eos
  end

  def int_stdin_int_stdout_test_code
    <<~eos
      ReflectionUtils.newInstanceOfClass(Submission.class);
      io.setSysIn("" + input);
      Submission.main(new String[0]);

      int out = Integer.parseInt(io.getSysOut());

      assertEquals(output, out);
    eos
  end

  def string_stdin_int_stdout_test_code
    <<~eos
      ReflectionUtils.newInstanceOfClass(Submission.class);
      io.setSysIn(input);
      Submission.main(new String[0]);

      int out = Integer.parseInt(io.getSysOut());

      assertEquals(output, out);
    eos
  end

  def int_stdin_string_stdout_test_code
    <<~eos
      ReflectionUtils.newInstanceOfClass(Submission.class);
      io.setSysIn("" + input);
      Submission.main(new String[0]);

      int out = io.getSysOut();

      assertEquals(output, out);
    eos
  end
end
