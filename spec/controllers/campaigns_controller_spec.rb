require 'rails_helper'

RSpec.describe CampaignsController, type: :controller do

  include Devise::Test::ControllerHelpers

  before(:each) do
    request.env["devise.mapping"] = Devise.mappings[:user]
    @current_user = FactoryBot.create(:user)
    sign_in @current_user
  end

  describe "GET #index" do
   it "returns http success" do
     get :index
     expect(response).to have_http_status(:success)
   end
  end

  describe 'GET #show' do
    context 'campaign exists' do
      context 'User is the owner of campaign' do
       it 'Returns success' do
         campaign = create(:campaign, user: @current_user)
         get :show, params: {id: campaign.id}
         expect(response).to have_http_status(:success)
       end
      end

      context 'User is not owner of campaign' do
       it 'Redirects to root' do
         campaign = create(:campaign)
         get(:show, params: {id:campaign.id})
         expect(response).to redirect_to('/')
       end
      end
    end

    context 'campaign don\'t exists' do
      it 'redirects to root' do
       get :show, params: {id: 0}
       expect(response).to redirect_to('/')
      end
    end
  end

  describe 'POST #create' do
    before(:each) do
     @campaign_attributes = attributes_for(:campaign, user: @current_user)
     post :create, params: {campaign: @campaign_attributes}
    end

    it 'Redirect to new campaign' do
     expect(response).to have_http_status(302)
     expect(response).to redirect_to("/campaigns/#{Campaign.last.id}")
    end

    it "Create campaign with right attributes" do
     expect(Campaign.last.user).to eql(@current_user)
     expect(Campaign.last.title).to eql(@campaign_attributes[:title])
     expect(Campaign.last.description).to eql(@campaign_attributes[:description])
     expect(Campaign.last.status).to eql(@campaign_attributes[:status])
    end

    it "Create campaign with owner associated as a member" do
     expect(Campaign.last.members.last.name).to eql(@current_user.name)
     expect(Campaign.last.members.last.email).to eql(@current_user.email)
    end
  end

end
