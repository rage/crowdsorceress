## Creating assignments

### 1. Course
First, you must create a course. Course only requires a name and the programming language it uses --
the choice of programming language will affect some properties, so make sure to choose the right one!
Currently, the system only supports Java for Finnish courses and Python for English courses.

### 2. Exercise type
Exercise types are the defining feature for assignments. If you have seeded the database according to [the setup
instructions](../README.md), you will have two exercise types (in Python)
you can use as an example when creating new exercise types. Exercise types have the following attributes:

* **Name (REQUIRED):** Something that describes the exercise type, for example, "input_output" for assignments that have only
input-output tests, or "io_and_code" for assignments with input-output tests and automatically generated test code for
students to fill in. snake_case is not required -- you can name your exercise types in any way you want, for example
"Readymade code - Hello, World!".

* **Testing type (REQUIRED):** Chosen from a dropdown menu. The first three (input_output, student_written_tests and io_and_code)
are used only in courses in which students create their own assignments, whereas the rest are used when the source code is given
by the instructor and the students are only required to create tests. The choices for the latter are:

  1. input_output_tests_for_set_up_code: Basic input-output tests for code given by the instructor.
  2. tests_for_set_up_code: The test code is generated so that the student needs to fill in the name of the test case, the
  assertion type and the basic input and output cases. Assertion type can be either AssertIn, AssertNotIn or AssertEqual
  (called contains, does not contain and equals in the frontend).
  3. whole_test_code_for_set_up_code: The student needs to write the at least three full test cases, the test method included.
  **Not supported in the English/Python version at the moment.** 

* **Code template (REQUIRED):** The code given by the instructor that the students see in the source code field. Tests
are created for this program. The system requires that the code template includes a main method that either contains the
functionality of the program or calls other methods. The system only creates and runs tests for the main method. **See
[example templates](./example_templates.md) in documentation for a code template example.**

* **Test template (REQUIRED)**: The simplest way is to use our [example test template](./example_templates.md).
If you want to create your own test template, be sure to include the `%<tests>s` placeholder tag in
an appropriate place, as this is where the system places the actual test methods.

* **Test method template:** This is required when the testing type tests_for_set_up_code is used. Test method template is
placed in the frontend and acts as a base for the students to fill in the rest of the test code. The simplest way is to use
our [example test method template](./example_templated.md). If you want to create your own test
method template, be sure to include placeholdes `<assertion>`, `<placeholderInput>` and `<placeholderOutput>`. 

The backend expects all inputs and outputs given by the students to be strings.

### 3. Assignment
Make sure that you have created your course and exercise type beforehand! Assignments have the following attributes:

* **Description (REQUIRED)**: Give your assignments a clear and distinguishable description. This can be for example "Basic Python
exercise with locked code template, string input and string output." or "Week 9 - More testing."

* **Exercise type (REQUIRED):** Choose from the list (see part 2 of this document for instructions).

* **Course (REQUIRED):** Choose from the list (see part 1 of this document for instructions).

* **Part:** Part or week of the course the assignment appears in. This can be used to track weekly points etc.

After creating an assignment, you'll be directed to a page that gives you the HTML required for embedding.

## Inspecting submissions

### 4. Exercises
You can inspect each submitted exercise individually. You can filter by assignment id or status.
