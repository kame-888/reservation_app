class Room < ApplicationRecord
  belongs_to :user
  has_one_attached :image
  has_many :reservations, dependent: :destroy

  scope :search, ->(keyword) {
    if keyword.present?
      where("name LIKE :kw OR address LIKE :kw", kw: "%#{keyword}%")
    end
  }
end
