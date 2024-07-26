class MembershipsController < ApplicationController
  def index
    @memberships = Membership.where(index_params)
    render json: @memberships
  end

  def show
    @membership = Membership.find(params[:id])
    render json: @membership  
  end

  def lookup
    @response = LookupMembershipService.call(lookup_params)
    render json: @response[:body], status: @response[:code]
  end

  def create
    @response = CreateMembershipService.call(membership_params)
    render json: @response[:body], status: @response[:code]
  end

  private

  def index_params
    params.permit(:role_id)
  end

  def lookup_params
    params.permit(:user_id, :team_id)
  end

  def membership_params
    params.permit(:role_id, :user_id, :team_id)
  end

end
