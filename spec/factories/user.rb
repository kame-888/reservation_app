FactoryBot.define do
  factory :user do
    sequence(:first_name)  { |n| "ユーザー#{n}" }
    sequence(:family_name)  { |n| "苗字#{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:password) { "1234abcd" }
  end
end
