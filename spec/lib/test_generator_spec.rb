# frozen_string_literal: true

require 'rails_helper'

TEST_TEMPLATE = <<~eos
  import fi.helsinki.cs.tmc.edutestutils.MockStdio;
  import fi.helsinki.cs.tmc.edutestutils.Points;
  import fi.helsinki.cs.tmc.edutestutils.ReflectionUtils;
  import org.junit.Rule;
  import org.junit.Test;
  import static org.junit.Assert.assertEquals;

  @Points("01-11")
  public class DoesThisEvenCompileTest {

  %<mock_stdio_init>s

    public DoesThisEvenCompileTest() {

    }

    %<tests>s

    private void toimii(%<IOtype>s input, %<IOtype>s output) {
      %<test_code>s
    }
  }
eos

RSpec.describe TestGenerator do
  describe 'Input to output test generator' do
    exercise = FactoryGirl.create(:exercise)

    test_code = 'assertEquals(output, DoesThisEvenCompile.metodi(input));'

    subject { TestGenerator.new }

    it 'is valid' do
      expect(subject).not_to be(nil)
    end

    it 'generates a proper test template when ExerciseType is "string_string"' do
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
      expect(subject).to respond_to(:generate).with(2).arguments
      expect(subject.generate(exercise, 'DoesThisEvenCompile')).to eq(format(TEST_TEMPLATE,
                                                                             tests: tests, IOtype: 'String', mock_stdio_init: '', test_code: test_code))
    end

    it 'generates a proper test template when ExerciseType is "int_int"' do
      exercise.assignment.exercise_type.name = 'int_int'
      io = [{ input: '3', output: '9' },
            { input: '4', output: '16' },
            { input: '1337', output: '1787569' }]

      exercise.testIO = io

      tests = <<~eos
        @Test
          public void test1() {
            toimii(3, 9);
          }

          @Test
          public void test2() {
            toimii(4, 16);
          }

          @Test
          public void test3() {
            toimii(1337, 1787569);
          }
eos
      expect(subject.generate(exercise, 'DoesThisEvenCompile')).to eq(format(TEST_TEMPLATE,
                                                                             tests: tests, IOtype: 'int',
                                                                             mock_stdio_init: '', test_code: test_code))
    end
  end

  describe 'String to stdout test generator' do
    exercise = FactoryGirl.create(:exercise)
    mock_stdio_init = <<~eos
      @Rule
      public MockStdio io = new MockStdio();
    eos

    test_code = <<~eos
      DoesThisEvenCompile.metodi(input);

      String out = io.getSysOut();
      assertEquals(output, out);
eos

    subject { TestGenerator.new }

    it 'is valid' do
      expect(subject).not_to be(nil)
    end

    it 'generates a proper test template' do
      exercise.assignment.exercise_type.name = 'string_stdout'

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
      expect(subject).to respond_to(:generate).with(2).arguments
      expect(subject.generate(exercise, 'DoesThisEvenCompile')).to eq(format(TEST_TEMPLATE,
                                                                             tests: tests, IOtype: 'String',
                                                                             mock_stdio_init: mock_stdio_init, test_code: test_code))
    end
  end

  describe 'Stdin to stdout test generator' do
    exercise = FactoryGirl.create(:exercise)
    mock_stdio_init = <<~eos
      @Rule
      public MockStdio io = new MockStdio();
    eos
    test_code = <<~eos
      ReflectionUtils.newInstanceOfClass(DoesThisEvenCompile.class);
      io.setSysIn(input);
      DoesThisEvenCompile.main(new String[0]);

      String out = io.getSysOut();

      assertEquals(output, out);
    eos

    subject { TestGenerator.new }

    it 'is valid' do
      expect(subject).not_to be(nil)
    end

    it 'generates a proper test template' do
      exercise.assignment.exercise_type.name = 'stdin_stdout'

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
      expect(subject).to respond_to(:generate).with(2).arguments
      expect(subject.generate(exercise, 'DoesThisEvenCompile')).to eq(format(TEST_TEMPLATE,
                                                                             tests: tests, IOtype: 'String',
                                                                             mock_stdio_init: mock_stdio_init, test_code: test_code))
    end
  end
end
