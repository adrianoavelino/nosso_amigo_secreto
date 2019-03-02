class CampaignsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_campaign, only: [:show, :destroy]
  before_action :is_owner?, only: [:show, :destroy]

  def show
  end

  def index
  end

  def create
    @campaign = Campaign.new(campaign_params)
    respond_to do |format|
      if @campaign.save
        format.html {redirect_to "/campaigns/#{@campaign.id}"}
      else
        format.html { redirect_to main_app.root_url, notice: @campaign.erros }
      end
    end
  end

  def update
  end

  def destroy
    @campaign.destroy
    respond_to do |format|
      format.json {render json: true}
    end
  end

  def raffle
  end

  private
  def campaign_params
    params.require(:campaign).permit(:title, :description, :status).merge(user: current_user)
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
