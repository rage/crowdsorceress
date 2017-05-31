FactoryGirl.define do
  factory :exercise do
    code 'dsd'
    description 'asd'
    input 'wdsf'
    output 'fsd'
    user
    exercise_type
  end

  factory :user do
    id 1
  end

  factory :exercise_type do
    id 1
  end
end
