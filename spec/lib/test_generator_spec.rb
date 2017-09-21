# frozen_string_literal: true

require 'rails_helper'

TEST_TEMPLATE = <<~eos
  import fi.helsinki.cs.tmc.edutestutils.MockStdio;
  import fi.helsinki.cs.tmc.edutestutils.Points;
  import fi.helsinki.cs.tmc.edutestutils.ReflectionUtils;
  import org.junit.Rule;
  import org.junit.Test;
  import static org.junit.Assert.assertEquals;
  import static org.junit.Assert.assertTrue;

  @Points("01-11")
  public class SubmissionTest {

      %<mock_stdio_init>s


      public SubmissionTest() {

      }

      %<tests>s

      private void toimii(%<inputType>s input, %<outputType>s output) {
          %<test_code>s
      }
  }
eos

RSpec.describe TestGenerator do
  before :each do
    allow_any_instance_of(MessageBroadcasterJob).to receive(:perform)
  end

  #   describe 'Input to output test generator' do
  #     exercise = FactoryGirl.create(:exercise)
  #
  #     test_code = 'assertEquals(output, Submission.metodi(input));'
  #
  #     subject { TestGenerator.new }
  #
  #     it 'is valid' do
  #       expect(subject).not_to be(nil)
  #     end
  #
  #     it 'generates a proper test template when ExerciseType is "string_string"' do
  #       io = [{ input: 'asd', output: 'asdasdasd' },
  #             { input: 'dsa', output: 'dsadsadsa' },
  #             { input: 'dsas', output: 'dsasdsasdsas' }]
  #
  #       exercise.testIO = io
  #
  #       tests = <<~eos
  #         @Test
  #           public void test1() {
  #             toimii("asd", "asdasdasd");
  #           }
  #
  #           @Test
  #           public void test2() {
  #             toimii("dsa", "dsadsadsa");
  #           }
  #
  #           @Test
  #           public void test3() {
  #             toimii("dsas", "dsasdsasdsas");
  #           }
  # eos
  #       expect(subject).to respond_to(:generate).with(1).argument
  #       expect(subject.generate(exercise)).to eq(format(TEST_TEMPLATE,
  #                                                       tests: tests, inputType: 'String', outputType: 'String', mock_stdio_init: '', test_code: test_code))
  #     end
  #
  #     it 'generates a proper test template when ExerciseType is "int_int"' do
  #       exercise.assignment.exercise_type.name = 'int_int'
  #       io = [{ input: '3', output: '9' },
  #             { input: '4', output: '16' },
  #             { input: '1337', output: '1787569' }]
  #
  #       exercise.testIO = io
  #
  #       tests = <<~eos
  #         @Test
  #           public void test1() {
  #             toimii(3, 9);
  #           }
  #
  #           @Test
  #           public void test2() {
  #             toimii(4, 16);
  #           }
  #
  #           @Test
  #           public void test3() {
  #             toimii(1337, 1787569);
  #           }
  # eos
  #       expect(subject.generate(exercise)).to eq(format(TEST_TEMPLATE, tests: tests, inputType: 'int', outputType: 'int',
  #                                                                      mock_stdio_init: '', test_code: test_code))
  #     end
  #   end

  #   describe 'String to stdout test generator' do
  #     exercise = FactoryGirl.create(:exercise)
  #     mock_stdio_init = <<~eos
  #       @Rule
  #       public MockStdio io = new MockStdio();
  #     eos
  #
  #     test_code = <<~eos
  #       Submission.metodi(input);
  #
  #       String out = io.getSysOut();
  #       assertEquals(output, out);
  # eos
  #
  #     subject { TestGenerator.new }
  #
  #     it 'is valid' do
  #       expect(subject).not_to be(nil)
  #     end
  #
  #     it 'generates a proper test template' do
  #       exercise.assignment.exercise_type.name = 'string_stdout'
  #
  #       io = [{ input: 'asd', output: 'asdasdasd' },
  #             { input: 'dsa', output: 'dsadsadsa' },
  #             { input: 'dsas', output: 'dsasdsasdsas' }]
  #
  #       exercise.testIO = io
  #
  #       tests = <<~eos
  #         @Test
  #           public void test1() {
  #             toimii("asd", "asdasdasd");
  #           }
  #
  #           @Test
  #           public void test2() {
  #             toimii("dsa", "dsadsadsa");
  #           }
  #
  #           @Test
  #           public void test3() {
  #             toimii("dsas", "dsasdsasdsas");
  #           }
  #       eos
  #       expect(subject).to respond_to(:generate).with(1).argument
  #       expect(subject.generate(exercise)).to eq(format(TEST_TEMPLATE,
  #                                                       tests: tests, inputType: 'String', outputType: 'String',
  #                                                       mock_stdio_init: mock_stdio_init, test_code: test_code))
  #     end
  #   end

  describe 'Stdin to stdout test generator' do
    exercise = FactoryGirl.create(:exercise)
    int_stdin_string_stdout_et = FactoryGirl.create(:int_stdin_string_stdout_et)
    string_stdin_string_stdout_et = FactoryGirl.create(:string_stdin_string_stdout_et)

    mock_stdio_init = <<~eos
      @Rule
          public MockStdio io = new MockStdio();
    eos

    int_int_test_code = <<~eos
      ReflectionUtils.newInstanceOfClass(Submission.class);
      io.setSysIn("" + input);
      Submission.main(new String[0]);

      int out = Integer.parseInt(io.getSysOut());

      assertEquals(output, out);
    eos

    string_int_test_code = <<~eos
      ReflectionUtils.newInstanceOfClass(Submission.class);
      io.setSysIn(input);
      Submission.main(new String[0]);

      int out = Integer.parseInt(io.getSysOut());

      assertEquals(output, out);
    eos

    subject { TestGenerator.new }

    it 'is valid' do
      expect(subject).not_to be(nil)
    end

    it 'generates a proper test template for string input and string output' do
      exercise.assignment.exercise_type = string_stdin_string_stdout_et

      io = [{ input: 'asd', output: 'asdasdasd' },
            { input: 'dsa', output: 'dsadsadsa' },
            { input: 'dsas', output: 'dsasdsasdsas' }]

      exercise.testIO = io

      tests = <<~eos
        @Test
            public void test1() {
                toimii("asd", "asdasdasd");
            }

        @Test
            public void test2() {
                toimii("dsa", "dsadsadsa");
            }

        @Test
            public void test3() {
                toimii("dsas", "dsasdsasdsas");
            }
      eos

      string_string_test_code = <<~eos
        ReflectionUtils.newInstanceOfClass(Submission.class);
                io.setSysIn(input);
                Submission.main(new String[0]);

                String out = io.getSysOut();

                assertTrue("Kun syöte oli '" + input.replaceAll("\\n", "\\\\\\n") + "' tulostus oli: '" + out.replaceAll("\\n", "\\\\\\n") + "', mutta se ei sisältänyt: '" + output.replaceAll("\\n", "\\\\\\n") + "'.", out.contains(output));
      eos

      expect(subject).to respond_to(:generate).with(1).argument
      expect(subject.generate(exercise)).to eq(format(TEST_TEMPLATE, tests: tests, inputType: 'String', outputType: 'String',
                                                                     mock_stdio_init: mock_stdio_init, test_code: string_string_test_code))
    end

    # it 'generates a proper test template for int input and int output' do
    #   exercise.assignment.exercise_type.name = 'int_stdin_int_stdout'
    #
    #   io = [{ input: 4, output: 5 },
    #         { input: 2, output: 7 },
    #         { input: 23_456, output: 23_456 }]
    #
    #   exercise.testIO = io
    #
    #   tests = <<~eos
    #     @Test
    #       public void test1() {
    #         toimii(4, 5);
    #       }
    #
    #       @Test
    #       public void test2() {
    #         toimii(2, 7);
    #       }
    #
    #       @Test
    #       public void test3() {
    #         toimii(23456, 23456);
    #       }
    #   eos
    #   expect(subject).to respond_to(:generate).with(1).argument
    #   expect(subject.generate(exercise)).to eq(format(TEST_TEMPLATE, tests: tests, inputType: 'int', outputType: 'int',
    #                                                                  mock_stdio_init: mock_stdio_init, test_code: int_int_test_code))
    # end

    # it 'generates a proper test template for string input and int output' do
    #   exercise.assignment.exercise_type.name = 'string_stdin_int_stdout'
    #
    #   io = [{ input: 'jea', output: 5 },
    #         { input: 'joo', output: 4 },
    #         { input: 'asd', output: 777 }]
    #
    #   exercise.testIO = io
    #
    #   tests = <<~eos
    #     @Test
    #       public void test1() {
    #         toimii("jea", 5);
    #       }
    #
    #       @Test
    #       public void test2() {
    #         toimii("joo", 4);
    #       }
    #
    #       @Test
    #       public void test3() {
    #         toimii("asd", 777);
    #       }
    #   eos
    #   expect(subject).to respond_to(:generate).with(1).argument
    #   expect(subject.generate(exercise)).to eq(format(TEST_TEMPLATE, tests: tests, inputType: 'String', outputType: 'int',
    #                                                                  mock_stdio_init: mock_stdio_init, test_code: string_int_test_code))
    # end

    it 'generates a proper test template for int input and string output' do
      exercise.assignment.exercise_type = int_stdin_string_stdout_et

      io = [{ input: 6, output: 'jea' },
            { input: 7, output: 'notjea' },
            { input: 98, output: '777' }]

      exercise.testIO = io

      tests = <<~eos
        @Test
            public void test1() {
                toimii(6, "jea");
            }

        @Test
            public void test2() {
                toimii(7, "notjea");
            }

        @Test
            public void test3() {
                toimii(98, "777");
            }
      eos

      int_string_test_code = <<~eos
        String inputAsString = "" + input;

                ReflectionUtils.newInstanceOfClass(Submission.class);
                io.setSysIn(inputAsString);
                Submission.main(new String[0]);

                String out = io.getSysOut();

                assertTrue("Kun syöte oli '" + inputAsString.replaceAll("\\n", "\\\\\\n") + "' tulostus oli: '" + out.replaceAll("\\n", "\\\\\\n") + "', mutta se ei sisältänyt: '" + output.replaceAll("\\n", "\\\\\\n") + "'.", out.contains(output));
      eos

      expect(subject).to respond_to(:generate).with(1).argument
      expect(subject.generate(exercise)).to eq(format(TEST_TEMPLATE, tests: tests, inputType: 'int', outputType: 'String',
                                                                     mock_stdio_init: mock_stdio_init, test_code: int_string_test_code))
    end

    # it 'raises error if exercise type is not supported' do
    #   pending 'implement code for this'
    #   exercise.assignment.exercise_type.name = 'stupid_exercie_type'
    #   expect { subject.generate(exercise) }.to raise_error(StandardError)
    # end
  end
end
