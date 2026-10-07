class Room < ApplicationRecord
  belongs_to :user
  has_one_attached :image
  has_many :reservations, dependent: :destroy

  validates :name, presence: true
  validates :description, presence: true
  validates :address, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 1 }

  scope :search, ->(keyword) {
    if keyword.present?
      where("address LIKE :kw", kw: "%#{keyword}%")
    end
  }
end
