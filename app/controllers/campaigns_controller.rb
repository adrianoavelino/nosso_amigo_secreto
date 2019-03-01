class CampaignsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_campaign, only: [:show]
  before_action :is_owner?, only: [:show]

  def show
  end

  def index
  end

  def create
  end

  def update
  end

  def destroy
  end

  def raffle
  end

  def set_campaign
    @campaign = Campaign.find(params[:id])
  end

  def is_owner?
    unless current_user == @campaign.user
      respond_to do |format|
        format.json { render json: false, status: :forbidden }
        format.html { redirect_to main_app.root_url }
      end
    end
  end
end
