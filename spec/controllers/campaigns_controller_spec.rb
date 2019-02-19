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

end
