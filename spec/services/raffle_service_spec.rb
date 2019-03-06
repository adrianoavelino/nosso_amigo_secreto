require 'rails_helper'

describe RaffleService do
  before(:each) do
    @campaign = create(:campaign)
  end

  describe '#call' do

    context 'When has more then two members' do
      before(:each) do
        create_list(:member, 5, campaign: @campaign)
        @campaign.reload
        @results = RaffleService.new(@campaign).call
      end

      it 'result is a hash' do
        expect(@results.class).to eq(Hash)
      end

      it 'all members are in results as a member' do
        result_member = @results.map { |r| r.first  }
        expect(result_member.sort).to eq(@campaign.members.sort)
      end

      it "a member don't get yourself" do
        @results.each do |r|
          expect(r.first).not_to eq(r.last)
        end
      end
    end

    context "when don't has more then two members" do
      before(:each) do
        create(:member, campaign: @campaign)
        @campaign.reload
        @response = RaffleService.new(@campaign).call
      end

      it "raise error" do
        expect(@response).to eql(false)
      end
    end

  end
end
