# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

admin = User.create email: 'admin@admin.com', administrator: true, username: 'admin'

users = []
(0..50).each do |i|
  users[i] = User.create email: "test#{i}@test.com", administrator: false, username: "test#{i}"
end

# CODE TEMPLATES:
code_template1 = "import java.util.*; \n // START LOCK \npublic class Submission {\n\n    public static void main(String[] args) {\n\n // END LOCK \n        //Kirjoita koodia tähän  \n    }\n\n    public static String metodi(String input) {\n\n        //Kirjoita koodia tähän \n    }\n}"

code_template2 = "import java.util.*; \npublic class Submission { \n // START LOCK  \n \n    public static void main(String[] args) { \n
// END LOCK \n\n        //Kirjoita koodia tähän  \n // LOCK TO END \n \n    }\n}"

code_template3 = "import java.util.Scanner;\n\npublic class Submission {\n\n    public static void main(String[] args) {\n\n        //Kirjoita koodia tähän \n    }\n\n   // LOCK TO END \n    public static void metodi(String input) {\n\n        //Kirjoita koodia tähän  \n    }\n}"

code_template4 =
<<~eos
import java.util.*; 
public class Submission {

    public static void main(String[] args) {
    // LOCK FROM BEGINNING
        Scanner lukija = new Scanner(System.in);
        suorita(lukija);
    // START LOCK  
    }

    public static void suorita(Scanner lukija) {
    // END LOCK

        //Kirjoita koodia tähän 
    // LOCK TO END

    }
}
eos

code_template5 = 
<<~eos
import java.util.*; 
public class Submission {

    public static void main(String[] args) {
        Scanner lukija = new Scanner(System.in);
        suorita(lukija); 
    }

    public static void suorita(Scanner lukija) {
        int luku = Integer.parseInt(lukija.nextLine());
        if (luku > 0) {
            System.out.println("positiivinen");
        } else if (luku == 0) {
            System.out.println("nolla");
        } else {
            System.out.println("negatiivinen");
        }
    }
}
eos

# TEST TEMPLATES
test_template1 =
<<~eos
  import fi.helsinki.cs.tmc.edutestutils.MockStdio;
  import fi.helsinki.cs.tmc.edutestutils.Points;
  import fi.helsinki.cs.tmc.edutestutils.ReflectionUtils;
  import org.junit.Rule;
  import org.junit.Test;
  import static org.junit.Assert.*;
  import java.util.Scanner;

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

test_template2 =
  <<~eos
  import org.junit.Test;
  import static org.junit.Assert.*;
  import fi.helsinki.cs.tmc.edutestutils.Points;
  
  @Points("01-11")
  public class SubmissionTest {
  
      public SubmissionTest() {
  
      }
      // LOCK FROM BEGINNING
  
      @Test
      public void test1() {
          toimii("syöte1", "odotettuTulos1");
      }
      // LOCK TO END

      private void toimii(String syöte, String odotettuTulos) {
          Submission submission = new Submission();
          assertTrue("Kun syöte oli '" + syöte + "' tulostus oli: '" + submission.metodi(syöte) + "', mutta se ei ollut: '" + odotettuTulos + "'.", submission.metodi(syöte).equals(odotettuTulos));
      }
  }
eos

test_template3 =
  <<~eos
  import org.junit.Test;
  import static org.junit.Assert.*;
  import fi.helsinki.cs.tmc.edutestutils.Points;
  
  @Points("01-11")
  public class SubmissionTest {
  
      public SubmissionTest() {
  
      }
  
      %<tests>s
      private void toimii(String syöte, String odotettuTulos) {
          Submission submission = new Submission();
          assertTrue("Kun syöte oli '" + syöte + "' tulostus oli: '" + submission.metodi(syöte) + "', mutta se ei ollut: '" + odotettuTulos + "'.", submission.metodi(syöte).equals(odotettuTulos));
      }
  }
eos

test_method_template1 = "@Test\npublic void <placeholderTestName> {\n    Submission.suorita(new Scanner(\"<placeholderInput>\"));\n    String metodinTulostus = io.getSysOut();\n    <assertion>\n}"

course = Course.create name: "test course"

# Exercise type 1
type = ExerciseType.create name: 'string_string', code_template: code_template1

assignments = []
assignments[0] = Assignment.create description: 'Tehtävän tarkoituksena on luoda metodi, joka saa parametrina string-tyyppisen muuttujan. Palautusarvo on myös string.', exercise_type: type, course: course, part: '1', show_results_to_user: true, mandatory_tags: true, peer_review_count: 3, pr_part: '2'

# Exercise type 2
type2 = ExerciseType.create name: 'string_stdin_string_stdout', code_template: code_template2, test_template: test_template1, input_type: 'String', output_type: 'String'

assignments[1] = Assignment.create description: 'Tee tehtävä, jonka tarkoitus on laittaa opiskelija koodaamaan ohjelma, joka lukee käyttäjältä merkkijonosyötteen, tarkastelee sitä ehtolauseen avulla ja tulostaa merkkijonon.
Anna testejä varten syöte-esimerkki ja ohjelman tuloste tuolla syötteellä.', exercise_type: type2, course: course, part: '1', show_results_to_user: true, mandatory_tags: true, peer_review_count: 3, pr_part: '2'

assignments[2] = Assignment.create description: 'Tee tehtävä, jonka tarkoitus on laittaa opiskelija koodaamaan ohjelma, joka lukee käyttäjältä merkkijonosyötteen, tarkastelee sitä toistolauseen avulla ja tulostaa merkkijonon.
Anna testejä varten syöte-esimerkki ja ohjelman tuloste tuolla syötteellä.', exercise_type: type2, course: course, part: '1', show_results_to_user: true, mandatory_tags: true, peer_review_count: 3, pr_part: '2'

# Exercise type 3
type3 = ExerciseType.create name: 'string_stdout', code_template: code_template3
Assignment.create description: 'Tee tehtävä, jossa pyydetään luomaan metodi, joka saa parametrina stringin. Metodin kuuluu tulostaa jokin merkkijono.', exercise_type: type3, course: course, part: '1', show_results_to_user: true, mandatory_tags: true, peer_review_count: 3, pr_part: '2'

# Exercise type 4
type4 = ExerciseType.create name: 'int_stdin_int_stdout', code_template: code_template2
assignments[3] = Assignment.create description: 'Tee tehtävä, jonka tarkoitus on laittaa opiskelija koodaamaan ohjelma, joka lukee käyttäjältä kokonaislukusyötteen, tarkastelee sitä ehtolauseen avulla ja tulostaa kokonaisluvun.
Anna testejä varten syöte-esimerkki ja ohjelman tuloste tuolla syötteellä.', exercise_type: type4, course: course, part: '1', show_results_to_user: true, mandatory_tags: true, peer_review_count: 3, pr_part: '2'

assignments[4] = Assignment.create description: 'Tee tehtävä, jonka tarkoitus on laittaa opiskelija koodaamaan ohjelma, joka lukee käyttäjältä kokonaislukusyötteen, tarkastelee sitä toistolauseen avulla ja tulostaa kokonaisluvun.
Anna testejä varten syöte-esimerkki ja ohjelman tuloste tuolla syötteellä.', exercise_type: type4, course: course, part: '1', show_results_to_user: true, mandatory_tags: true, peer_review_count: 3, pr_part: '2'

# Exercise type 5
type5 = ExerciseType.create name: 'string_stdin_int_stdout', code_template: code_template2
assignments[5] = Assignment.create description: 'Tee tehtävä, jonka tarkoitus on laittaa opiskelija koodaamaan ohjelma, joka lukee käyttäjältä merkkijonosyötteen, tarkastelee sitä toistolauseen avulla ja tulostaa kokonaisluvun.
Anna testejä varten syöte-esimerkki ja ohjelman tuloste tuolla syötteellä.', exercise_type: type5, course: course, part: '1', show_results_to_user: true, mandatory_tags: true, peer_review_count: 3, pr_part: '2'

# Exercise type 6
type6 = ExerciseType.create name: 'int_stdin_string_stdout', code_template: code_template2
assignments[6] = Assignment.create description: 'Tee tehtävä, jonka tarkoitus on laittaa opiskelija koodaamaan ohjelma, joka lukee käyttäjältä kokonaislukusyötteen, tarkastelee sitä ehtolauseen avulla ja tulostaa merkkijonon.
Anna testejä varten syöte-esimerkki ja ohjelman tuloste tuolla syötteellä.', exercise_type: type6, course: course, part: '1', show_results_to_user: true, mandatory_tags: true, peer_review_count: 3, pr_part: '2'

# Exercise type 7
type7 = ExerciseType.create name: 'junit_tests', code_template: code_template1, test_template: test_template2, testing_type: 1
assignments[7] = Assignment.create description: 'Tee tehtävä ja kirjoita sille yksikkötestit', exercise_type: type7, course: course, part: '1', show_results_to_user: true, mandatory_tags: true, peer_review_count: 3, pr_part: '2'

# Exercise type 8
type8 = ExerciseType.create name: 'io_and_test_code', code_template: code_template4, test_template: test_template1, testing_type: 2, test_method_template: test_method_template1
assignments[8] = Assignment.create description: 'Tee tehtävä, anna sille testisyötteet ja -tulosteet ja näe kuinka ne näkyvät testikoodissa!', exercise_type: type8, course: course, part: '1', show_results_to_user: true, mandatory_tags: true, peer_review_count: 3, pr_part: '2'

# Exercise type 9
type9 = ExerciseType.create name: 'input_output_tests_for_set_up_code', code_template: code_template5, test_template: test_template1, testing_type: 5
assignments[9] = Assignment.create description: 'Tee ttestit valmiille tehtävälle', exercise_type: type9, course: course, part: '1', show_results_to_user: true, mandatory_tags: true, peer_review_count: 3, pr_part: '2'

# Peer review questions:

PeerReviewQuestion.create question: 'Tehtävänannon mielekkyys', exercise_type: type
PeerReviewQuestion.create question: 'Testien kattavuus', exercise_type: type
PeerReviewQuestion.create question: 'Tehtävänannon selkeys', exercise_type: type
PeerReviewQuestion.create question: 'Epätodennäköisen pitkä ja luultavasti vaikeasti ymmärrettävä vertaisarviointikysymys', exercise_type: type

PeerReviewQuestion.create question: 'Tehtävä on toteutettu hyvällä maulla', exercise_type: type2
PeerReviewQuestion.create question: 'Testien ja koodin oikeellisuus', exercise_type: type2
PeerReviewQuestion.create question: 'Tehtävänannon selkeys', exercise_type: type2
PeerReviewQuestion.create question: 'Tehtävän parhaustaso', exercise_type: type2

PeerReviewQuestion.create question: 'Tehtävänannon mielekkyys', exercise_type: type3
PeerReviewQuestion.create question: 'Tehtävän tyylikkyys', exercise_type: type3
PeerReviewQuestion.create question: 'Testi-IO:n järkevyys', exercise_type: type3
PeerReviewQuestion.create question: 'Tehtävän parhaustaso', exercise_type: type3

tags = []

tags[0] = Tag.create name: 'java', recommended: true
tags[1] = Tag.create name: 'for-loop', recommended: true
tags[2] = Tag.create name: 'while-loop'
tags[3] = Tag.create name: 'error', recommended: true
tags[4] = Tag.create name: 'scanner'
tags[5] = Tag.create name: 'metodi', recommended: true
tags[6] = Tag.create name: 'luokka'
tags[8] = Tag.create name: 'olio', recommended: true
tags[7] = Tag.create name: 'muuttuja'

Exercise.create user: users[0], assignment: assignments[0], code: 'import java.util.*; \n // START LOCK \npublic class Submission {\n\n    public static void main(String[] args) {\n\n // END LOCK \n        //Kirjoita koodia tähän  \n  // BEGIN SOLUTION \n \n System.out.println("Olen testi"); \n // END SOLUTION
 \n \n  }\n\n}', testIO: JSON[{input: 'asd', output: 'Olen testi'}].to_json, description: {nodes: [{kind: 'block', type: 'paragraph', nodes: [{ kind: 'text', text: 'Tee joku hieno tehtävä jossa teet hienoja asioita.' }]}]}, status: 5, sandbox_results: { status: '', message: 'Tehtäväpohjan tulokset: Kaikki OK. Malliratkaisun tulokset: Kaikki OK.', passed: true, 'model_results_received': true, template_results_received: true} , peer_reviews_count: 0, model_solution: 'import java.util.*; \n // START LOCK \npublic class Submission {\n\n    public static void main(String[] args) {\n\n // END LOCK \n        //Kirjoita koodia tähän  \n \n System.out.println("Olen testi"); \n \n  }\n\n}', template: 'import java.util.*; \n // START LOCK \npublic class Submission {\n\n    public static void main(String[] args) {\n\n // END LOCK \n        //Kirjoita koodia tähän  \n \n  }\n\n}', error_messages: [], submit_count: 0

 Exercise.create user: users[1], assignment: assignments[0], code: 'import java.util.*; \n // START LOCK \npublic class Submission {\n\n    public static void main(String[] args) {\n\n // END LOCK \n        //Kirjoita koodia tähän  \n  // BEGIN SOLUTION \n \n System.out.println("Olen testi2"); \n // END SOLUTION
 \n \n  }\n\n}', testIO: JSON[{input: 'asd', output: 'Olen testi2'}].to_json, description: {nodes: [{kind: 'block', type: 'paragraph', nodes: [{ kind: 'text', text: 'Tee joku hieno tehtävä jossa teet hienoja asioita.' }]}]}, status: 5, sandbox_results: { status: '', message: 'Tehtäväpohjan tulokset: Kaikki OK. Malliratkaisun tulokset: Kaikki OK.', passed: true, 'model_results_received': true, template_results_received: true} , peer_reviews_count: 0, model_solution: 'import java.util.*; \n // START LOCK \npublic class Submission {\n\n    public static void main(String[] args) {\n\n // END LOCK \n        //Kirjoita koodia tähän  \n \n System.out.println("Olen testi"); \n \n  }\n\n}', template: 'import java.util.*; \n // START LOCK \npublic class Submission {\n\n    public static void main(String[] args) {\n\n // END LOCK \n        //Kirjoita koodia tähän  \n \n  }\n\n}', error_messages: [], submit_count: 0

 Exercise.create user: admin, assignment: assignments[0], code: 'import java.util.*; \n // START LOCK \npublic class Submission {\n\n    public static void main(String[] args) {\n\n // END LOCK \n        //Kirjoita koodia tähän  \n  // BEGIN SOLUTION \n \n System.out.println("Olen testi"); \n // END SOLUTION
 \n \n  }\n\n}', testIO: JSON[{input: 'asd', output: 'Olen testi'}].to_json, description: {nodes: [{kind: 'block', type: 'paragraph', nodes: [{ kind: 'text', text: 'Tee joku hieno tehtävä jossa teet hienoja asioita.' }]}]}, status: 5, sandbox_results: { status: '', message: 'Tehtäväpohjan tulokset: Kaikki OK. Malliratkaisun tulokset: Kaikki OK.', passed: true, 'model_results_received': true, template_results_received: true} , peer_reviews_count: 0, model_solution: 'import java.util.*; \n // START LOCK \npublic class Submission {\n\n    public static void main(String[] args) {\n\n // END LOCK \n        //Kirjoita koodia tähän  \n \n System.out.println("Olen testi"); \n \n  }\n\n}', template: 'import java.util.*; \n // START LOCK \npublic class Submission {\n\n    public static void main(String[] args) {\n\n // END LOCK \n        //Kirjoita koodia tähän  \n \n  }\n\n}', error_messages: [], submit_count: 0

 Exercise.create user: users[1], assignment: assignments[1], code: 'import java.util.*; \n // START LOCK \npublic class Submission {\n\n    public static void main(String[] args) {\n\n // END LOCK \n        //Kirjoita koodia tähän  \n  // BEGIN SOLUTION \n \n System.out.println("Yes this is code"); \n // END SOLUTION
 \n \n  }\n\n}', testIO: JSON[{input: 'asd', output: 'Yes this is code'}].to_json, description: {nodes: [{kind: 'block', type: 'paragraph', nodes: [{ kind: 'text', text: 'Tee joku hieno tehtävä jossa teet hienoja asioita.' }]}]}, status: 5, sandbox_results: { status: '', message: 'Tehtäväpohjan tulokset: Kaikki OK. Malliratkaisun tulokset: Kaikki OK.', passed: true, 'model_results_received': true, template_results_received: true} , peer_reviews_count: 0, model_solution: 'import java.util.*; \n // START LOCK \npublic class Submission {\n\n    public static void main(String[] args) {\n\n // END LOCK \n        //Kirjoita koodia tähän  \n \n System.out.println("Olen testi"); \n \n  }\n\n}', template: 'import java.util.*; \n // START LOCK \npublic class Submission {\n\n    public static void main(String[] args) {\n\n // END LOCK \n        //Kirjoita koodia tähän  \n \n  }\n\n}', error_messages: [], submit_count: 0


(0..200).each do |i|
  j = Random.rand(assignments.length)
  k = Random.rand(users.length)
  t = Random.rand(tags.length)
  Exercise.create user: users[k], assignment: assignments[j], code: 'import java.util.*; \n // START LOCK \npublic class Submission {\n\n    public static void main(String[] args) {\n\n // END LOCK \n        //Kirjoita koodia tähän  \n  // BEGIN SOLUTION \n \n System.out.println("Yes this is code"); \n // END SOLUTION
  \n \n  }\n\n}', testIO: JSON[{input: 'asd', output: 'Yes this is code'}].to_json, description: {nodes: [{kind: 'block', type: 'paragraph', nodes: [{ kind: 'text', text: 'Tee joku hieno tehtävä jossa teet hienoja asioita.' }]}]}, status: 5, sandbox_results: { status: '', message: 'Tehtäväpohjan tulokset: Kaikki OK. Malliratkaisun tulokset: Kaikki OK.', passed: true, 'model_results_received': true, template_results_received: true} , peer_reviews_count: 0, model_solution: 'import java.util.*; \n // START LOCK \npublic class Submission {\n\n    public static void main(String[] args) {\n\n // END LOCK \n        //Kirjoita koodia tähän  \n \n System.out.println("Olen testi"); \n \n  }\n\n}', template: 'import java.util.*; \n // START LOCK \npublic class Submission {\n\n    public static void main(String[] args) {\n\n // END LOCK \n        //Kirjoita koodia tähän  \n \n  }\n\n}', error_messages: [], submit_count: 0, tags: [tags[t]]
end
