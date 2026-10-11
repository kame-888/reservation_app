FactoryBot.define do
  factory :room do
    sequence(:name)  { |n| "111ホテル＃#{n}" }
    description              { "ようこそ" }
    price                  { 1000 }
    address                 { "東京都111区" }
    association :user
  end
end
