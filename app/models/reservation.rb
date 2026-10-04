class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :room

  validates :checkin_at, presence: true, comparison: { greater_than_or_equal_to: -> { Time.zone.today } }
  validates :checkout_at, presence: true, comparison: { greater_than: :checkin_at, allow_nil: true }
  validates :guest_count, presence: true, comparison: { greater_than_or_equal_to: 1 }

  def total
    return 0 if room.blank? || guest_count.blank?
    guest_count * room.price * nights
  end
  
  def nights
    return 0 if checkin_at.blank? || checkout_at.blank?
    (checkout_at - checkin_at).to_i
  end
end
