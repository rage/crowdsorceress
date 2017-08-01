# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

type = ExerciseType.create name: 'string_string'
a1 = Assignment.create description: 'Luo tekoäly', exercise_type: type

type2 = ExerciseType.create name: 'stdin_stdout'
Assignment.create description: 'Tulosta tekoäly', exercise_type: type2

type3 = ExerciseType.create name: 'string_stdout'
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
