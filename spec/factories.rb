FactoryGirl.define do
  factory :exercise do
    code 'asd'
    description 'asd'
    IO 'asd'
    user
    exercise_type
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
    name 'asd'
    test_template 'asd'
  end
end
