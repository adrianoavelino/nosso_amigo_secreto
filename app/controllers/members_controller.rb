class MembersController < ApplicationController
  before_action :authenticate_user!, except: [:opened]
  before_action :set_member, only: [:destroy]
  before_action :is_owner?, only: [:destroy]

  def create
    @member = Member.new(member_params)
    @campaign = Campaign.find(@member.campaign_id)
    if current_user != @campaign.user
      respond_to do |format|
        format.json { render json: false, status: :forbidden }
      end
    else
      respond_to do |format|
        if @member.save
          format.json { render json: @member }
        else
          format.json { render json: @member.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def destroy
    @member.destroy
    respond_to do |format|
      format.json { render json: true }
    end
  end

  def update
  end

  def member_params
    params.require(:member).permit(:name, :email, :campaign_id)
  end

  def is_owner?
    unless current_user == @member.campaign.user
      respond_to do |format|
        format.json { render json: false, status: :forbidden }
      end
    end
  end

  def set_member
    @member = Member.find(params[:id])
  end

end
