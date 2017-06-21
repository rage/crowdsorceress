# frozen_string_literal: true

class MainClassGenerator
  TEMPLATE = <<~eos
    public class DoesThisEvenCompile {

      public static void main(String[] args) {

      }

      public static %<output_type>s metodi(%<input_type>s input) {
        %<code>s
      }
    }
  eos

  def generate(exercise)
    type = exercise.assignment.exercise_type.name

    # input_to_output(exercise, type) if type == 'string_string' || type == 'int_int'
    input_to_output(exercise, type) if %w[string_string int_int].include?(type)
  end

  def input_to_output(exercise, type) # input and output both exist
    if type == 'string_string'
      input_type = 'String'
      output_type = 'String'
    end

    if type == 'int_int'
      input_type = 'int'
      output_type = 'int'
    end

    format(TEMPLATE, input_type: input_type, output_type: output_type, code: exercise.code)
  end
end
