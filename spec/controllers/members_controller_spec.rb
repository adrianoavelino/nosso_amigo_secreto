require 'rails_helper'

RSpec.describe MembersController, type: :controller do
  include Devise::Test::ControllerHelpers

  before(:each) do
    request.env["devise.mapping"] = Devise.mappings[:user]
    @current_user = FactoryBot.create(:user)
  end

  describe "POST #create" do
    context 'As Logged User' do
      context 'User is the Campaign\'s Owner' do
        it "returns http found" do
          request.env['HTTP_ACCEPT'] = 'application/json'
          sign_in @current_user

          campaign = create(:campaign, user: @current_user)
          member_attributes = attributes_for(:member, campaign_id: campaign.id)

          post :create, params: {member: member_attributes, campaign_id: campaign.id }

          expect(response).to have_http_status(:success)
        end

        it 'change count by 1' do
          request.env['HTTP_ACCEPT'] = 'application/json'
          sign_in @current_user

          campaign = create(:campaign, user: @current_user)
          member_attributes = attributes_for(:member, campaign_id: campaign.id)

          expect {
            post :create, params: { member: member_attributes, campaign_id: campaign.id }
          }
          .to change(Member, :count).by(1)
        end
      end

      context 'User isn\'t the Campaign Owner' do
        it 'return http forbidden to response json' do
          request.env['HTTP_ACCEPT'] = 'application/json'
          sign_in @current_user

          campaign = create(:campaign)
          member_attributes = attributes_for(:member, campaign_id: campaign.id)

          post :create, params: {member: member_attributes, campaign_id: campaign.id }
          expect(response).to have_http_status(:forbidden)
        end

        it 'redirect to root to response html' do
          request.env['HTTP_ACCEPT'] = 'application/json'
          sign_in @current_user

          campaign = create(:campaign)
          member_attributes = attributes_for(:member, campaign_id: campaign.id)

          post :create, params: {member: member_attributes }
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'As User not Logged in' do
      it 'redirect to login' do
        campaign = create(:campaign, user: @current_user)
        campaign2 = create(:campaign)
        member_attributes = attributes_for(:member, campaign_id: campaign.id)

        post :create, params: {member: member_attributes }

        expect(response).to redirect_to(user_session_path)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'As Logged User' do
      context 'User is the Campaign\'s Owner' do
        it 'return success' do
          request.env['HTTP_ACCEPT'] = 'application/json'
          sign_in @current_user

          campaign = create(:campaign, user: @current_user)
          member = create(:member, campaign_id: campaign.id)

          delete :destroy, params: {id: member.id, campaign_id: campaign.id}
          expect(response).to be_success
        end

        it 'change count by -1' do
          request.env['HTTP_ACCEPT'] = 'application/json'
          sign_in @current_user

          campaign = create(:campaign, user: @current_user)
          member = create(:member, campaign_id: campaign.id)
          create(:member)
          total = Member.count

          expect {
            delete :destroy, params: { id: member.id, campaign_id: campaign.id }
          }
          .to change(Member, :count).by(-1)
        end
      end

      context 'User isn\'t the Campaign Owner' do
        it 'return http forbidden to response json' do
          request.env['HTTP_ACCEPT'] = 'application/json'
          sign_in @current_user

          campaign = create(:campaign)
          member = create(:member, campaign_id: campaign.id)

          delete :destroy, params: {id: member.id, campaign_id: campaign.id}
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'As User not Logged in' do
      it 'redirect to login' do
        request.env['HTTP_ACCEPT'] = 'application/json'
        campaign = create(:campaign, user: @current_user)
        member_attributes = attributes_for(:member, campaign_id: campaign.id)

        post :create, params: {member: member_attributes }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

end
