class Member < ApplicationRecord
  belongs_to :campaign
  before_save :set_email_like_not_opened
  after_save :set_campaign_pending
  validates :name, :email, :campaign, presence: true

  def set_pixel
    self.open = false
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless Member.exists?(token: random_token)
    end
    self.save!
  end

  protected
  def set_campaign_pending
    self.campaign.update(status: :pending)
  end

  def set_email_like_not_opened
    self.open = false if self.new_record?
  end
end
