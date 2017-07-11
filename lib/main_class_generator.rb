# frozen_string_literal: true

class MainClassGenerator
  TEMPLATE = <<~eos
    public class %<class_name>s {

        public static void main(String[] args) {
    %<code>s
        }

    %<input_output_code>s
    }
eos

  def generate(exercise, class_name)
    type = exercise.assignment.exercise_type.name

    if type == 'stdin_stdout'
      stdin_to_stdout(exercise, class_name)
    elsif %w[string_string int_int].include?(type)
      input_to_output(exercise, type, class_name)
    end
  end

  def stdin_to_stdout(exercise, class_name)
    format(TEMPLATE, code: exercise.code, class_name: class_name, input_output_code: '')
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

    input_output_code = <<-eos
    public static #{output_type} metodi(#{input_type} input) {
        #{exercise.code}
    }
eos

    format(TEMPLATE, class_name: class_name, input_output_code: input_output_code, code: '')
  end
end
