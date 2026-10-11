FactoryBot.define do
  factory :reservation do
    checkin_at  { Date.current + 1.day }
    checkout_at { Date.current + 3.days }
    guest_count  { 5 }
    association :user
    association :room
  end
end
