# frozen_string_literal: true

FactoryGirl.define do
  factory :peer_review_question_answer do
    grade 1
    peer_review nil
    peer_review_question nil
  end
  factory :peer_review_question do
    question 'MyString'
    exercise_type nil
  end
  factory :peer_review do
    user nil
    exercise nil
    comment 'MyText'
  end
  factory :assignment do
    description 'AAAAAAAA'
    exercise_type
  end

  factory :exercise do
    code 'asd'
    description 'asd'
    assignment
    user
    testIO [{ "input": 'lol', "output": 'lolled' }]
  end

  factory :user do
    email 'user@email.com'
    first_name 'asd'
    last_name 'dsa'
    administrator false
    username 'asd'
    last_logged_in nil
  end

  factory :exercise_type do
    name 'string_string'
    test_template 'asd'
  end
end
