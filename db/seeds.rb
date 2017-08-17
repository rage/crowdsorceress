# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

code_template1 = " import java.util.*; \n // START LOCK \n public class Submission {\n\n    public static void main(String[] args)
{\n\n // END LOCK \n//Kirjoita koodia tähän  \n  }\n\n        public static String metodi(String input) {\n\n // Hax hax hax \n }\n}"

code_template2 = " import java.utils.* \npublic class Submission { \n // START LOCK  \n \n  public static void main(String[] args) { \n
// END LOCK \n\n  // Tee jotain fiksua  \n // LOCK TO END \n \n }\n}"

code_template3 = "import java.util.Scanner;\n\npublic class Submission {\n\n    public static void main(String[] args) {\n\n // Hax hax hax \n
}\n\n   // LOCK TO END \n public static void metodi(String input) {\n\n // Hax hax hax  \n  }\n}"

type = ExerciseType.create name: 'string_string', code_template: code_template1
a1 = Assignment.create description: 'Luo tekoäly', exercise_type: type

type2 = ExerciseType.create name: 'stdin_stdout', code_template: code_template2
Assignment.create description: 'Tulosta tekoäly', exercise_type: type2

type3 = ExerciseType.create name: 'string_stdout', code_template: code_template3
Assignment.create description: 'Käytä tekoäly', exercise_type: type3

Exercise.create(
  code: 'int luku = 1; \n String kissa = \"koira \"; \n return \"Palautusarvo \" ',
  assignment: a1,
  testIO: { input: 'Hello', output: 'Hello testi' }
)
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

Tag.create name: 'java', recommended: true
Tag.create name: 'for-loop', recommended: true
Tag.create name: 'while-loop'
Tag.create name: 'error', recommended: true
Tag.create name: 'scanner'
Tag.create name: 'metodi', recommended: true
Tag.create name: 'luokka'
Tag.create name: 'olio', recommended: true
Tag.create name: 'muuttuja'
