require "rails_helper"

RSpec.describe CampaignMailer, type: :mailer do
  describe "raffle" do
    before(:each) do
      @campaign = create(:campaign)
      @member = create(:member)
      @friend = create(:member)
      @mail = CampaignMailer.raffle(@campaign, @member, @friend)
    end

    it 'renders the headers' do

      expect(@mail.subject).to eq("Nosso Amigo Secreto: #{@campaign.title}")
      expect(@mail.to).to eq([@member.email])
    end

    it 'body have member name' do
      expect(@mail.body.encoded).to match(@member.name)
    end

    it 'body have campaign creator name' do
      expect(@mail.body.encoded).to match(@campaign.user.name)
    end

    it 'body have member link o set open' do
      expect(@mail.body.encoded).to match(/members\/[\s\w=]*\/opened/)
    end
  end

end
