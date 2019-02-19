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
     end
   end

end
