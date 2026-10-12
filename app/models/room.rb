class Room < ApplicationRecord
  belongs_to :user
  has_one_attached :image do |attachable|
    attachable.variant :thumb, resize_to_fill: [ 80, 80 ], format: :jpeg, preprocessed: true
    attachable.variant :card,  resize_to_fill: [ 800, 600 ], format: :jpeg, preprocessed: true
  end
  has_many :reservations, dependent: :destroy

  validates :name, presence: true
  validates :description, presence: true
  validates :address, presence: true
  validates :price, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  scope :search, ->(keyword) {
    if keyword.present?
      where("address LIKE :kw", kw: "%#{sanitize_sql_like(keyword)}%")
    end
  }
end
