class TeamClient
  include HTTParty

  attr_reader :users

  base_uri ENV.fetch('TEAM_SERVICE_URI', 'https://0.0.0.0')

  def self.fetch_team(id)
    Rails.logger.info "Fetching team information for team_id '#{id}'..."
    response = get("/teams/#{id}")
    return new(JSON.parse(response.body)) if response.code == 200 && response.body != "null"

    Rails.logger.error "Error while fetching team information for team_id '#{id}'"
    raise App::ClientError
  rescue StandardError => e
    Rails.logger.error "Error while fetching team information for team_id '#{id}'"
    Rails.logger.error e.backtrace.join("\n")

    raise App::ClientError
  end

  def initialize(data)
    @users = [data["teamLeadId"], data["teamMemberIds"]].flatten
  end  
end