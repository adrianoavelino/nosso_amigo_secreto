class Campaign < ApplicationRecord
  belongs_to :user
  has_many :members, dependent: :destroy

  validates :title, :description, :user, :status, presence: true
end
