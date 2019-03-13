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

  describe 'PUT #update' do
    before(:each) do
      request.env['HTTP_ACCEPT'] = 'application/json'
    end
    context 'As Logged User' do
      context 'User is the Campaign\'s Owner' do
        before(:each) do
          @campaign = create(:campaign, user: @current_user)
          @member = create(:member, campaign_id: @campaign.id)
          @member_updated = attributes_for(:member, campaign_id: @campaign.id)
          sign_in @current_user
          put :update, params: { id: @member.id, member: @member_updated }
        end

        it 'return success' do
          expect(response).to have_http_status(:success)
        end

        it 'member has updated attributes' do
          expect(Member.last.name).to eq(@member_updated[:name])
          expect(Member.last.email).to eq(@member_updated[:email])
        end
      end

      context 'User isn\'t the Campaign Owner' do
        before(:each) do
          @campaign = create(:campaign, user: @current_user)
          @member = create(:member)
          @member_updated = attributes_for(:member, campaign_id: @campaign.id)
          sign_in @current_user
          put :update, params: { id: @member.id, member: @member_updated }
        end

        it 'return http forbidden to response json' do
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'As User not Logged in' do
      before(:each) do
        @campaign = create(:campaign, user: @current_user)
        @member = create(:member, campaign: @campaign)
        @member_updated = attributes_for(:member, campaign_id: @campaign.id)
        put :update, params: { id: @member.id, member: @member_updated }
      end

      it 'return http unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'OPENED' do
    before(:each) do
      request.env['HTTP_ACCEPT'] = 'application/json'
    end

    it 'return success' do
      member =  create(:member)
      get :opened, params: {token: member.token }
      expect(response).to have_http_status(:success)
    end

    it 'change attribute open to true' do
      member = create(:member)
      expect {
        get :opened, params: {token: member.token }
      }.to change{Member.last.open}.from(false).to(true)
    end
  end

end
