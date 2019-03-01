require 'rails_helper'

RSpec.describe CampaignsController, type: :controller do

  include Devise::Test::ControllerHelpers

   describe "GET #index" do
     it "returns http success" do
       request.env["devise.mapping"] = Devise.mappings[:user]
       current_user = FactoryBot.create(:user)
       sign_in current_user
       get :index
       expect(response).to have_http_status(:success)
     end
   end

   describe 'GET #show' do
     context 'campaign exists' do
       context 'User is the owner of campaign' do
         it 'Returns success' do
           request.env["devise.mapping"] = Devise.mappings[:user]
           current_user = FactoryBot.create(:user)
           campaign = create(:campaign, user: current_user)
           sign_in current_user
           get :show, params: {id: campaign.id}
           expect(response).to have_http_status(:success)
         end
       end

       context 'User is not owner of campaign' do
         it 'Redirects to root' do
           request.env["devise.mapping"] = Devise.mappings[:user]
           current_user = FactoryBot.create(:user)
           sign_in current_user
           campaign = create(:campaign)
           get(:show, params: {id:campaign.id})
           expect(response).to redirect_to('/')
         end
       end

       context 'campaign don\'t exists' do
         it 'redirects to root' do
           request.env["devise.mapping"] = Devise.mappings[:user]
           current_user = FactoryBot.create(:user)

           sign_in current_user
           get :show, params: {id: 0}
           expect(response).to redirect_to('/')
         end
       end

       describe 'POST #create' do
         it 'Redirect to new campaign' do
           request.env["devise.mapping"] = Devise.mappings[:user]
           current_user = FactoryBot.create(:user)
           sign_in current_user
           campaign_attributes = attributes_for(:campaign, user: current_user)
           post :create, params: {campaign: campaign_attributes}

           expect(response).to have_http_status(302)
           expect(response).to redirect_to("/campaigns/#{Campaign.last.id}")
         end
       end

     end
   end

end
