# frozen_string_literal: true

require 'rails_helper'

TEST_TEMPLATE = <<~eos
  import fi.helsinki.cs.tmc.edutestutils.Points;
  import static org.junit.Assert.assertEquals;
  import org.junit.Test;

  @Points("01-11")
  public class DoesThisEvenCompileTest {

    public DoesThisEvenCompileTest() {

    }

    %{tests}

    private void toimii(%<IOtype>s input, %<IOtype>s output) {
      assertEquals(output, DoesThisEvenCompile.metodi(input));
    }
  }
eos

RSpec.describe TestGenerator do
  describe 'Input to output generator' do
    exercise = FactoryGirl.create(:exercise)

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
eos
      expect(subject).to respond_to(:generate).with(1).argument
      expect(subject.generate(exercise)).to eq(format(TEST_TEMPLATE, tests: tests, IOtype: 'String'))
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
      expect(subject.generate(exercise)).to eq(format(TEST_TEMPLATE, tests: tests, IOtype: 'int'))
    end
  end
end
