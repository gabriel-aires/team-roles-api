class RolesController < ApplicationController

  def index
    @roles = Role.all
    render json: @roles
  end

  def show
    @role = Role.find(params[:id])
    render json: @role
  end

  def create
    @role = Role.new(role_params)
    @role.save!
    render json: @role, status: :created
  end

  private

  def role_params
    params.permit(:name, :is_default)
  end
end
