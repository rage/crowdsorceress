# frozen_string_literal: true

require 'rails_helper'

TEMPLATE = <<~eos
  import java.util.Scanner;

  public class DoesThisEvenCompile {

      public static void main(String[] args) {
  %<code>s
      }

  %<method>s

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

      method = <<-eos
    public static String metodi(String input) {
        #{exercise.code}
    }

eos

      expect(subject).to respond_to(:generate).with(2).arguments
      expect(subject.generate(exercise, 'DoesThisEvenCompile')).to eq(format(TEMPLATE, code: '', method: method))
    end

    it 'generates a proper main class when ExerciseType is "int_int"' do
      exercise.assignment.exercise_type.name = 'int_int'
      io = [{ input: '4', output: '5' }]
      exercise.testIO = io
      exercise.code = <<~eos
        int kissa = 6;
        return 5;
eos

      method = <<-eos
    public static int metodi(int input) {
        #{exercise.code}
    }

eos

      expect(subject.generate(exercise, 'DoesThisEvenCompile')).to eq(format(TEMPLATE, code: '', method: method))
    end
  end

  describe 'String to stdout generator' do
    exercise = FactoryGirl.create(:exercise)
    exercise.assignment.exercise_type.name = 'string_stdout'

    subject { MainClassGenerator.new }

    it 'is valid' do
      expect(subject).not_to be(nil)
    end

    it 'generates a proper main class' do
      io = [{ input: 'asd', output: 'asdasdasd' }]
      exercise.testIO = io
      exercise.code = 'System.out.print("jea");'

      method = <<-eos
    public static void metodi(String input) {
        #{exercise.code}
    }

eos

      expect(subject).to respond_to(:generate).with(2).arguments
      expect(subject.generate(exercise, 'DoesThisEvenCompile')).to eq(format(TEMPLATE, code: '', method: method))
    end
  end

  describe 'Stdin to stdout generator' do
    exercise = FactoryGirl.create(:exercise)
    exercise.assignment.exercise_type.name = 'stdin_stdout'

    subject { MainClassGenerator.new }

    it 'is valid' do
      expect(subject).not_to be(nil)
    end

    it 'generates a proper main class' do
      io = [{ input: 'asd', output: 'asdasdasd' }]
      exercise.testIO = io
      exercise.code = <<~eos
        Scanner lukija = new Scanner(System.in);
        String rivi = lukija.nextLine();
        System.out.print(rivi);
eos

      expect(subject).to respond_to(:generate).with(2).arguments
      expect(subject.generate(exercise, 'DoesThisEvenCompile')).to eq(format(TEMPLATE, code: exercise.code, method: ''))
    end
  end
end
