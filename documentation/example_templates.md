These are example templates for exercise types.

### Code template:

~~~~
def greeting():
  name = input()
  print("Hello,", name)

def main(): #required! see admin instruction for more info
  greeting()

if __name__ == '__main__':
  main()
~~~~

### Test template:
~~~~
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
~~~~  

This template is used by the backend. Test cases are inserted into the placeholder `%<tests>s`.


### Test method template:
~~~~
  @patch('sys.stdout', new_callable=io.StringIO)

  def <placeholderTestName>:
    with patch('builtins.input', side_effect=["<placeholderInput>"]):
      main()
      actual_output = mock_stdout.getvalue()
    <assertion>
~~~~
    
This template is sent to the frontend, which gives the user-given inputs in place of the placeholders and forms
the assertion (either AssertIn, AssertNotIn or AssertEqual).
