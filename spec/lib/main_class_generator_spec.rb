# frozen_string_literal: true

require 'rails_helper'

TEMPLATE = <<~eos
  public class DoesThisEvenCompile {

      public static void main(String[] args) {

      }

      public static %<IOtype>s metodi(%<IOtype>s input) {
          %<code>s
      }

  }
eos

RSpec.describe MainClassGenerator do
  describe 'Input to output generator' do
    exercise = FactoryGirl.create(:exercise)

    subject { MainClassGenerator.new }

    it 'is valid' do
      expect(subject).not_to be(nil)
    end

    it 'generates a proper main class when ExerciseType is "string_string"' do
      io = [{ input: 'asd', output: 'asdasdasd' }]
      exercise.testIO = io
      exercise.code = 'return "asdasdasd";'

      expect(subject).to respond_to(:generate).with(2).arguments
      expect(subject.generate(exercise, 'DoesThisEvenCompile')).to eq(format(TEMPLATE, IOtype: 'String', code: exercise.code))
    end

    it 'generates a proper main class when ExerciseType is "int_int"' do
      exercise.assignment.exercise_type.name = 'int_int'
      io = [{ input: '4', output: '5' }]
      exercise.testIO = io
      exercise.code = <<~eos
        int kissa = 6;
        return 5;
eos

      expect(subject.generate(exercise, 'DoesThisEvenCompile')).to eq(format(TEMPLATE, IOtype: 'int', code: exercise.code))
    end
  end
end
