class LookupMembershipService < ApplicationService

  def call
    @errors << "The user_id is required" unless @params[:user_id]
    @errors << "The team_id is required" unless @params[:team_id]

    return error_response(@errors) unless @errors.empty?

    membership = Membership.find_by!(@params)
    success_response(membership)
  end

end