require 'rails_helper'
require 'test_generator'

RSpec.describe TestGenerator do
  describe 'String->String generator' do
    exercise_type = FactoryGirl.create(:exercise_type)
    assignment = FactoryGirl.create(:assignment)
    exercise = FactoryGirl.create(:exercise)

    code = <<-eos
      public class Class {

          public static void main(String[] args) {
              String asia = "asia";
              method(asia);
          }

          public static String method(String input) {
              System.out.print(input);
              System.out.print(input);
              System.out.print(input);
              return input + input + input;
          }
      }
    eos

    io = [{ input: 'asd', output: 'asdasdasd' },
          { input: 'dsa', output: 'dsadsadsa' },
          { input: 'dsas', output: 'dsasdsasdsas' }]

    exercise.testIO = io
    exercise.code = code

    test_template = <<-eos.strip_heredoc
      import static org.junit.Assert.assertEquals;
      import org.junit.Test;

      public class ClassTest {

        @Test
        public void test1() {
          toimii(asd, asdasdasd);
        }

        @Test
        public void test2() {
          toimii(dsa, dsadsadsa);
        }

        @Test
        public void test3() {
          toimii(dsas, dsasdsasdsas);
        }


        private void toimii(String input, String output) {
          assertEquals(output, Class.method(input));
        }
      }
    eos

    subject { TestGenerator.new }

    it 'is valid' do
      expect(subject).not_to be(nil)
    end

    it 'generates a test template' do
      expect(subject).to respond_to(:generate).with(1).argument
      expect(subject.generate(exercise)).to eq(test_template)
    end
  end

  describe 'Int->Int generator' do
    exercise_type = FactoryGirl.build(:exercise_type)
    assignment = FactoryGirl.build(:assignment, exercise_type: exercise_type)
    exercise = FactoryGirl.build(:exercise, assignment: assignment)

    exercise.assignment.exercise_type.name = 'int_int'

    code = <<-eos
      public class Class {

          public static void main(String[] args) {
              int a = 1337;
              System.out.println(method(a));
          }

          public static int method(int input) {
              return input * input;
          }
      }
    eos

    io = [{ input: '3', output: '9' },
          { input: '4', output: '16' },
          { input: '1337', output: '1787569' }]

    exercise.testIO = io
    exercise.code = code

    test_template = <<-eos.strip_heredoc
      import static org.junit.Assert.assertEquals;
      import org.junit.Test;

      public class ClassTest {

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


        private void toimii(int input, int output) {
          assertEquals(output, Class.method(input));
        }
      }
    eos

    subject { TestGenerator.new }

    it 'is valid' do
      expect(subject).not_to be(nil)
    end

    it 'generates a test template' do
      expect(subject).to respond_to(:generate).with(1).argument
      expect(subject.generate(exercise)).to eq(test_template)
    end
  end
end
