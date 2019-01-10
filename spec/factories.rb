# frozen_string_literal: true

FactoryGirl.define do
  factory :course do
    name "MyString"
  end
  factory :tag do
    name 'tag'
  end

  factory :exercise_type do
    name 'string_string'
    test_template 'asd'
  end

  factory :string_string_et, class: ExerciseType do
    name 'string_string'
    test_template <<~eos
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

          


          public SubmissionTest() {

          }

          %<tests>s
          private void toimii(String input, String output) {
              assertEquals(output, Submission.metodi(input));
          }
      }
    eos
    input_type 'String'
    output_type 'String'
  end

  factory :string_input_string_stdout_et, class: ExerciseType do
    name 'string_input_string_stdout'
    input_type 'String'
    output_type 'String'

    test_template <<~eos
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
          private void toimii(String input, String output) {
              Submission.metodi(input);

              String out = io.getSysOut();
              assertEquals(output, out);

          }
      }
    eos
  end

  factory :int_stdin_string_stdout_et, class: ExerciseType do
    name 'int_stdin_string_stdout'
    test_template <<~eos
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
          private void toimii(int input, String output) {
              String inputAsString = "" + input;

              ReflectionUtils.newInstanceOfClass(Submission.class);
              io.setSysIn(inputAsString);
              Submission.main(new String[0]);

              String out = io.getSysOut();

              assertTrue("Kun syöte oli '" + inputAsString.replaceAll("\\n", "\\\\\\n") + "' tulostus oli: '" + out.replaceAll("\\n", "\\\\\\n") + "', mutta se ei sisältänyt: '" + output.replaceAll("\\n", "\\\\\\n") + "'.", out.contains(output));

          }
      }
    eos
    input_type 'int'
    output_type 'String'
  end

  factory :string_stdin_string_stdout_et, class: ExerciseType do
    name 'string_stdin_string_stdout'
    input_type 'String'
    output_type 'String'
    test_template <<~eos
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
          private void toimii(String input, String output) {
              ReflectionUtils.newInstanceOfClass(Submission.class);
              io.setSysIn(input);
              Submission.main(new String[0]);

              String out = io.getSysOut();

              assertTrue("Kun syöte oli '" + input.replaceAll("\\n", "\\\\\\n") + "' tulostus oli: '" + out.replaceAll("\\n", "\\\\\\n") + "', mutta se ei sisältänyt: '" + output.replaceAll("\\n", "\\\\\\n") + "'.", out.contains(output));

          }
      }
    eos
  end

  factory :assignment do
    description 'AAAAAAAA'
    exercise_type
    course
  end

  factory :peer_review_question do
    question 'Tehtävän mielekkyys'
    exercise_type
  end

  factory :peer_review_question_answer do
    grade 1
    peer_review
    peer_review_question
  end

  factory :user do
    email 'user@email.com'
    first_name 'asd'
    last_name 'dsa'
    administrator false
    username 'asd'
    last_logged_in nil
  end

  factory :exercise do
    sequence(:code) { |n| "int nmbr = #{n}; \n int scnd = 2;" }
    description 'Make good code code please'
    assignment
    user
    testIO [{ "input": 'lol', "output": 'lolled', "type": 'positive' }]
  end

  factory :peer_review do
    user
    exercise
    comment 'Hyvin menee'
  end
end
