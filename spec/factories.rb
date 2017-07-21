# frozen_string_literal: true

FactoryGirl.define do
  factory :tag do
    name 'tai'
  end

  factory :exercise_type do
    name 'string_string'
    test_template 'asd'
  end

  factory :assignment do
    description 'AAAAAAAA'
    exercise_type
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
    testIO [{ "input": 'lol', "output": 'lolled' }]
  end

  factory :peer_review do
    user
    exercise
    comment 'Hyvin menee'
  end
end
