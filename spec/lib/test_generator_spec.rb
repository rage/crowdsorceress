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
  import static org.junit.Assert.assertFalse;

  @Points("01-11")
  public class SubmissionTest {

      %<mock_stdio_init>s


      public SubmissionTest() {

      }

      %<tests>s

      private void testPositiveCase(%<inputType>s input, %<outputType>s output) {
          %<test_code>s
      }

      private void testNegativeCase(%<inputType>s input, %<outputType>s output) {
          %<neg_test_code>s
      }
  }
eos

RSpec.describe TestGenerator do # TODO: change testio type if necessary
  before :each do
    allow_any_instance_of(MessageBroadcasterJob).to receive(:perform)
  end

  describe 'Input to output test generator' do
    exercise = FactoryGirl.create(:exercise)
    string_string_et = FactoryGirl.create(:string_string_et)

    test_code = 'assertEquals(output, Submission.metodi(input));'

    subject { TestGenerator.new }

    it 'is valid' do
      expect(subject).not_to be(nil)
    end

    it 'generates a proper test template when ExerciseType is "string_string"' do
      io = [{ input: 'asd', output: 'asdasdasd', type: 'positive' },
            { input: 'dsa', output: 'dsadsadsa', type: 'positive' },
            { input: 'dsas', output: 'dsasdsasdsas', type: 'positive' }]

      exercise.testIO = io
      exercise.assignment.exercise_type = string_string_et

      tests = <<~eos
        @Test
            public void test1() {
                testPositiveCase("asd", "asdasdasd");
            }

        @Test
            public void test2() {
                testPositiveCase("dsa", "dsadsadsa");
            }

        @Test
            public void test3() {
                testPositiveCase("dsas", "dsasdsasdsas");
            }
  eos
      expect(subject).to respond_to(:generate).with(1).argument
      expect(subject.generate(exercise)).to eq(format(TEST_TEMPLATE, tests: tests, inputType: 'String',
                                                                     outputType: 'String', mock_stdio_init: '', test_code: test_code, neg_test_code: ''))
    end
  end

  describe 'String to stdout test generator' do
    exercise = FactoryGirl.create(:exercise)
    string_input_string_stdout_et = FactoryGirl.create(:string_input_string_stdout_et)

    mock_stdio_init = <<~eos
      @Rule
          public MockStdio io = new MockStdio();
      eos

    test_code = <<~eos
      Submission.metodi(input);

              String out = io.getSysOut();
              assertEquals(output, out);
  eos

    subject { TestGenerator.new }

    it 'is valid' do
      expect(subject).not_to be(nil)
    end

    it 'generates a proper test template' do
      exercise.assignment.exercise_type.name = 'string_stdout'

      io = [{ input: 'asd', output: 'asdasdasd', type: 'positive' },
            { input: 'dsa', output: 'dsadsadsa', type: 'positive' },
            { input: 'dsas', output: 'dsasdsasdsas', type: 'positive' }]

      exercise.testIO = io
      exercise.assignment.exercise_type = string_input_string_stdout_et

      tests = <<~eos
        @Test
            public void test1() {
                testPositiveCase("asd", "asdasdasd");
            }

        @Test
            public void test2() {
                testPositiveCase("dsa", "dsadsadsa");
            }

        @Test
            public void test3() {
                testPositiveCase("dsas", "dsasdsasdsas");
            }
        eos
      expect(subject).to respond_to(:generate).with(1).argument
      expect(subject.generate(exercise)).to eq(format(TEST_TEMPLATE,
                                                      tests: tests, inputType: 'String', outputType: 'String',
                                                      mock_stdio_init: mock_stdio_init, test_code: test_code, neg_test_code: ''))
    end
  end

  describe 'Stdin to stdout test generator' do
    exercise = FactoryGirl.create(:exercise)
    int_stdin_string_stdout_et = FactoryGirl.create(:int_stdin_string_stdout_et)
    string_stdin_string_stdout_et = FactoryGirl.create(:string_stdin_string_stdout_et)

    mock_stdio_init = <<~eos
      @Rule
          public MockStdio io = new MockStdio();
    eos

    string_string_test_code = <<~eos
      ReflectionUtils.newInstanceOfClass(Submission.class);
              io.setSysIn(input);
              Submission.main(new String[0]);

              String out = io.getSysOut();

              assertTrue("Kun syöte oli '" + input.replaceAll("\\n", "\\\\\\n") + "' tulostus oli: '" + out.replaceAll("\\n", "\\\\\\n") + "', mutta se ei sisältänyt: '" + output.replaceAll("\\n", "\\\\\\n") + "'.", out.contains(output));
    eos

    string_string_neg_test_code = <<~eos
      ReflectionUtils.newInstanceOfClass(Submission.class);
              io.setSysIn(input);
              Submission.main(new String[0]);

              String out = io.getSysOut();

              assertFalse("Kun syöte oli '" + input.replaceAll("\\n", "\\\\\\n") + "' tulostus oli: '" + out.replaceAll("\\n", "\\\\\\n") + "', mutta se sisälsi: '" + output.replaceAll("\\n", "\\\\\\n") + "', vaikkei niin saanut olla.", out.contains(output));
    eos

    subject { TestGenerator.new }

    it 'is valid' do
      expect(subject).not_to be(nil)
    end

    it 'generates a proper test template for string input and string output' do
      exercise.assignment.exercise_type = string_stdin_string_stdout_et

      io = [{ input: 'asd', output: 'asdasdasd', type: 'positive' },
            { input: 'dsa', output: 'dsadsadsa', type: 'positive' },
            { input: 'dsas', output: 'dsasdsasdsas', type: 'positive' }]

      exercise.testIO = io

      tests = <<~eos
        @Test
            public void test1() {
                testPositiveCase("asd", "asdasdasd");
            }

        @Test
            public void test2() {
                testPositiveCase("dsa", "dsadsadsa");
            }

        @Test
            public void test3() {
                testPositiveCase("dsas", "dsasdsasdsas");
            }
      eos

      expect(subject).to respond_to(:generate).with(1).argument
      expect(subject.generate(exercise)).to eq(format(TEST_TEMPLATE, tests: tests, inputType: 'String',
                                                                     outputType: 'String', mock_stdio_init: mock_stdio_init,
                                                                     test_code: string_string_test_code, neg_test_code: string_string_neg_test_code))
    end

    it 'generates a proper test template for int input and string output' do
      exercise.assignment.exercise_type = int_stdin_string_stdout_et

      io = [{ input: 6, output: 'jea', type: 'positive' },
            { input: 7, output: 'notjea', type: 'positive' },
            { input: 98, output: '777', type: 'positive' }]

      exercise.testIO = io

      tests = <<~eos
        @Test
            public void test1() {
                testPositiveCase(6, "jea");
            }

        @Test
            public void test2() {
                testPositiveCase(7, "notjea");
            }

        @Test
            public void test3() {
                testPositiveCase(98, "777");
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
                                                                     mock_stdio_init: mock_stdio_init, test_code: int_string_test_code, neg_test_code: ''))
    end

    it 'raises error if test template does not exist' do
      exercise.assignment.exercise_type.test_template = ''
      expect { subject.generate(exercise) }.to raise_error(StandardError)
    end

    it 'generates negative test cases' do
      exercise.assignment.exercise_type = string_stdin_string_stdout_et
      exercise.testIO = [{ input: '123', output: 'ykskakskolme', type: 'positive' },
                         { input: '321', output: 'kolmekaksyks', type: 'positive' },
                         { input: '321', output: 'ykskakskolme', type: 'negative' },
                         { input: '123', output: 'jeajeajea', type: 'negative' }]

      tests = <<~eos
        @Test
            public void test1() {
                testPositiveCase("123", "ykskakskolme");
            }

        @Test
            public void test2() {
                testPositiveCase("321", "kolmekaksyks");
            }

        @Test
            public void test3() {
                testNegativeCase("321", "ykskakskolme");
            }

        @Test
            public void test4() {
                testNegativeCase("123", "jeajeajea");
            }
      eos

      expect(subject).to respond_to(:generate).with(1).argument
      expect(subject.generate(exercise)).to eq(format(TEST_TEMPLATE, tests: tests, inputType: 'String',
                                                                     outputType: 'String', mock_stdio_init: mock_stdio_init,
                                                                     test_code: string_string_test_code, neg_test_code: string_string_neg_test_code))
    end
  end
end
