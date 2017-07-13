# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

type = ExerciseType.create name: 'string_string'
Assignment.create description: 'Luo tekoäly', exercise_type: type

type2 = ExerciseType.create name: 'stdin_stdout'
Assignment.create description: 'Tulosta tekoäly', exercise_type: type2

type3 = ExerciseType.create name: 'string_stdout'
Assignment.create description: 'Käytä tekoäly', exercise_type: type3
a = Assignment.create description: 'Luo tekoäly', exercise_type: type
Exercise.create code: 'int luku = 1; \n String kissa = \"koira \"; \n return \"Palautusarvo \" ', assignment: a, testIO: { input: 'Hello', output: 'Hello testi' }
PeerReviewQuestion.create question: 'Tehtävänannon mielekkyys', exercise_type: type
PeerReviewQuestion.create question: 'Testien kattavuus', exercise_type: type
PeerReviewQuestion.create question: 'Tehtävänannon selkeys', exercise_type: type
PeerReviewQuestion.create question: 'Epätodennäköisen pitkä ja luultavasti vaikeasti ymmärrettävä vertaisarviointikysymys', exercise_type: type
