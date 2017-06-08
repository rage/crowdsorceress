FactoryGirl.define do
  factory :assignment do
    description 'MyString'
    exercise_type
  end

  factory :exercise do
    code 'asd'
    description 'asd'
    user
    assignment
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
