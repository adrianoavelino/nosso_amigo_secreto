class Campaign < ApplicationRecord
  belongs_to :user
  has_many :members, dependent: :destroy
  before_create :set_member

  validates :title, :description, :user, :status, presence: true

  def set_member
    self.members << Member.create(name: self.user.name, email: self.user.email)
  end
end
