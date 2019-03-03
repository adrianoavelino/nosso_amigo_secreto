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

  describe 'DELETE #destroy' do
    before(:each) do
      request.env['HTTP_ACCEPT'] = 'application/json'
    end

    context 'User is the Campaign Owner' do
      before(:each) do
        @campaign = create(:campaign, user: @current_user)
      end
      it 'returns http success' do
        delete :destroy, params: {id: @campaign.id}
        expect(response).to have_http_status(:success)
      end

      it 'delete campaign from database' do
        amountCampaign = Campaign.all.count
        expect(amountCampaign).to eq(1)
        delete :destroy, params: {id: @campaign.id}
        expect(Campaign.all.count).to eq(0)
      end
    end

    context 'User isn\'t the Campaign Owner' do
      it 'returns http forbidden' do
        campaign = create(:campaign)
        delete :destroy, params: {id: campaign.id}
        expect(response).to have_http_status(:forbidden)
      end

      it 'don\'t delete campaign from database' do
        campaign = create(:campaign)
        amountCampaign = Campaign.all.count

        expect(amountCampaign).to eq(1)
        delete :destroy, params: {id: campaign.id}
        expect(Campaign.all.count).to eq(1)
      end
    end

  end

  context 'PUT #update' do
    before(:each) do
      @new_campaign_attributes = attributes_for(:campaign)
      request.env['HTTP_ACCEPT'] = 'application/json'
    end

    context 'User is the Campaign Owner' do
      before(:each) do
        @campaign = create(:campaign, user: @current_user)
      end

      it 'returns http success' do
        put :update, params: { id: @campaign.id, campaign: @new_campaign_attributes }
        expect(response).to have_http_status(:success)
      end

      it 'Campaign has updated attributes' do
        put :update, params: { id: @campaign.id, campaign: @new_campaign_attributes }
        expect(Campaign.last.title).to eq(@new_campaign_attributes[:title])
        expect(Campaign.last.description).to eq(@new_campaign_attributes[:description])
      end
    end

    context 'User isn\'t the Campaign Owner' do
      it 'returns http forbidden' do
        user = create(:user)
        campaign = create(:campaign)
        put :update, params: { id: campaign.id, campaign: @new_campaign_attributes }
        expect(response).to have_http_status(:forbidden)
      end

      it 'Campaign don\'t has updated attributes' do
        user = create(:user)
        campaign = create(:campaign)
        put :update, params: { id: campaign.id, campaign: @new_campaign_attributes }
        expect(Campaign.last.title).not_to eq(@new_campaign_attributes[:title])
        expect(Campaign.last.description).not_to eq(@new_campaign_attributes[:description])
      end
    end
  end

  describe 'GET #raffle' do
    before(:each) do
      request.env['HTTP_ACCEPT'] = 'application/json'
    end

    context 'User is the Campaign Owner' do
      before(:each) do
        @campaign = create(:campaign, user: @current_user)
      end

      context 'Has more than two members' do
        it 'return success' do
          create(:member, campaign: @campaign)
          create(:member, campaign: @campaign)
          create(:member, campaign: @campaign)
          post :raffle, params: { id: @campaign.id }
          expect(response).to have_http_status(:success)
          expect(response.parsed_body).to match('true')
        end
      end

      context 'No more than two members' do
        it 'returns http unprocessable_entity' do
          create(:member, campaign: @campaign)
          post :raffle, params: { id: @campaign.id }
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body).to match('A campanha precisa de pelo menos 3 pessoas')
        end
      end

      context 'The Campaign has been finished' do
        it 'return http unprocessable_entity' do
          campaign = create(:campaign, status: 1, user: @current_user)
          post :raffle, params: { id: campaign.id }
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body).to match('Já foi sorteada')
        end
      end
    end

    context 'User isn\'t the Campaign Owner' do
      it 'return http forbidden' do
        user = create(:user)
        campaign = create(:campaign, user: user)
        post :raffle, params: { id: campaign.id }
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body).to match('false')
      end
    end

  end
end
