# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

admin = User.create email: 'admin@admin.com', administrator: true, username: 'admin'

course = Course.create name: "Python course", language: "Python"

code_template1 =
<<~eos
def greeting():
  name = input()
  print("Hello,", name)

def main():
  greeting()

if __name__ == '__main__':
  main()
eos

test_template1 =
<<~eos
import unittest
from unittest.mock import patch
import io
from tmc.utils import load

submission = load("src.submission", "submission")
main = load("src.submission", "main")

class TestSubmission(unittest.TestCase):

%<tests>s

if __name__ == '__main__':
  unittest.main()
eos

test_method_template1 =
<<~eos
  \u0020\u0020@patch('sys.stdout', new_callable=io.StringIO)

  \u0020\u0020def <placeholderTestName>:
  \u0020\u0020\u0020\u0020with patch('builtins.input', side_effect=["<placeholderInput>"]):
  \u0020\u0020\u0020\u0020\u0020\u0020main()
  \u0020\u0020\u0020\u0020\u0020\u0020actual_output = mock_stdout.getvalue()
  \u0020\u0020\u0020\u0020<assertion>
eos

exercise_type1 = ExerciseType.create name: 'input_output', code_template: code_template1, test_template: test_template1, testing_type: 5

exercise_type2 = ExerciseType.create name: 'io_and_code', code_template: code_template1, test_template: test_template1, testing_type: 3, test_method_template: test_method_template1

assignment1 = Assignment.create description: 'Basic Python exercise with locked code template, string input and string output.', exercise_type: exercise_type1, course: course, part: '1', show_results_to_user: true, mandatory_tags: false, peer_review_count: 0, pr_part: '1'

assignment2 = Assignment.create description: 'Python exercise with automatically generated test method, string input and string output.', exercise_type: exercise_type2, course: course, part: '1', show_results_to_user: true, mandatory_tags: false, peer_review_count: 0, pr_part: '1'
