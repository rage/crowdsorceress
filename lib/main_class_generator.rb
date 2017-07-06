# frozen_string_literal: true

class MainClassGenerator
  TEMPLATE = <<~eos
    public class %<class_name>s {

      public static void main(String[] args) {

      }

      public static %<output_type>s metodi(%<input_type>s input) {
        %<code>s
      }
    }
  eos

  def generate(exercise, class_name)
    type = exercise.assignment.exercise_type.name

    input_to_output(exercise, type, class_name) if %w[string_string int_int].include?(type)
  end

  def input_to_output(exercise, type, class_name) # input and output both exist
    if type == 'string_string'
      input_type = 'String'
      output_type = 'String'
    end

    if type == 'int_int'
      input_type = 'int'
      output_type = 'int'
    end

    format(TEMPLATE, input_type: input_type, output_type: output_type, code: exercise.code, class_name: class_name)
  end
end
