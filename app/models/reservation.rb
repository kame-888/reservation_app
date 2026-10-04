class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :room

  def total
    return 0 if room.blank? || guest_count.blank?
    guest_count * room.price * nights
  end
  
  def nights
    return 0 if checkin_at.blank? || checkout_at.blank?
    (checkout_at - checkin_at).to_i
  end
end
