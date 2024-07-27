class CreateMembershipService < ApplicationService

  def call
    @errors << "The user_id is required" unless @params[:user_id]
    @errors << "The team_id is required" unless @params[:team_id]

    return error_response(@errors) unless @errors.empty?

    team = TeamClient.fetch_team(@params[:team_id])

    return member_error_response unless @params[:user_id].in? team.users

    persist_membership
  rescue App::ClientError
    client_error_response
  end

  private

  def persist_membership
    if @params[:role_id].present?
      role = Role.find(@params[:role_id])
      membership = Membership.new(user_id: @params[:user_id], team_id: @params[:team_id], role:)
    else
      membership = Membership.new(@params)
    end

    membership.save!
    success_response(membership, :created)
  end

  def client_error_response
    error_response(["Couldn't find the team referenced by the given team_id"])
  end

  def member_error_response
    error_response(["The user_id is not associated with the given team_id"])
  end
end