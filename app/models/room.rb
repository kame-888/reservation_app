class Room < ApplicationRecord
  belongs_to :user
  has_one_attached :image
  has_many :reservations, dependent: :destroy

  scope :search, ->(keyword) {
    if keyword.present?
      where("address LIKE :kw", kw: "%#{keyword}%")
    end
  }
end
