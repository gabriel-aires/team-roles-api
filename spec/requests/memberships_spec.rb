require 'rails_helper'

RSpec.describe "Memberships", type: :request do
  let(:user_one) { "00000000-1111-2222-3333-aaaaaaaaaaaa" }
  let(:user_two) { "00000000-1111-2222-3333-bbbbbbbbbbbb" }
  let(:user_three) { "00000000-1111-2222-3333-cccccccccccc" }
  let(:team) { "00000000-1111-2222-3333-dddddddddddd" }
  let(:service_uri) { ENV.fetch("TEAM_SERVICE_URI") }

  before do
    stub_request(:get, "#{service_uri}/teams/#{team}")
      .to_return(
        status: 200,
        body: {
          id: team,
          name: "test",
          teamLeadId: user_one,
          teamMemberIds: [user_two, user_three]
        }.to_json
      )

    post "/roles", params: { name: "Developer", is_default: true }
    @role_one = JSON.parse(response.body)

    post "/roles", params: { name: "Tester" }
    @role_two = JSON.parse(response.body)

    post "/memberships", params: { user_id: user_one, team_id: team, role_id: @role_one["id"] }
    @membership_one = JSON.parse(response.body)

    post "/memberships", params: { user_id: user_two, team_id: team, role_id: @role_two["id"] }
    @membership_two = JSON.parse(response.body)
  end

  describe "GET /memberships" do
    it "returns all memberships" do
      get "/memberships"
      json = JSON.parse(response.body)
      
      expect(response).to have_http_status(:success)
      expect(json.size).to eq(2)
    end
  end

  describe "GET /memberships?role_id=:role_id" do
    it "returns all memberships filtered by role_id" do
      get "/memberships?role_id=#{@role_two["id"]}"
      json = JSON.parse(response.body)
      
      expect(response).to have_http_status(:success)
      expect(json.size).to eq(1)
      expect(json.first).to eq(@membership_two)
    end
  end

  describe "GET /memberships/:id" do
    it "returns a membership by id" do
      get "/memberships/#{@membership_one["id"]}"
      json = JSON.parse(response.body)

      expect(response).to have_http_status(:success)
      expect(json["id"]).to eq(@membership_one["id"])
      expect(json["user_id"]).to eq(@membership_one["user_id"])
      expect(json["team_id"]).to eq(@membership_one["team_id"])
      expect(json["role"]).to eq(@role_one)
    end
  end

  describe "GET /memberships/lookup?user_id=:user_id&team_id=:team_id" do
    context "with valid parameters" do
      it "returns a membership by user_id and team_id" do
        get "/memberships/lookup?user_id=#{user_one}&team_id=#{team}"
        json = JSON.parse(response.body)

        expect(response).to have_http_status(:success)
        expect(json["id"]).to eq(@membership_one["id"])
        expect(json["user_id"]).to eq(@membership_one["user_id"])
        expect(json["team_id"]).to eq(@membership_one["team_id"])
        expect(json["role"]).to eq(@role_one)      
      end
    end

    context "with wrong parameters" do
      it "returns not found" do
        get "/memberships/lookup?user_id=0&team_id=0"
        json = JSON.parse(response.body)

        expect(response).to have_http_status(:not_found)
        expect(json["errors"]).not_to be_empty
        expect(json["errors"].first).to eq("Membership not found")
      end
    end

    context "without parameters" do
      it "returns bad request" do
        get "/memberships/lookup"
        json = JSON.parse(response.body)

        expect(response).to have_http_status(:bad_request)
        expect(json["errors"]).not_to be_empty
      end      
    end
  end

  describe "POST /memberships" do
    context "with valid parameters" do
      it "creates a membership" do
        expect {
          post "/memberships", params: { user_id: user_three, team_id: team }
        }.to change { Membership.count }.by(1)
        
        json = JSON.parse(response.body)

        expect(response).to have_http_status(:created)
        expect(json["id"]).not_to be_nil
        expect(json["user_id"]).to eq(user_three)
        expect(json["team_id"]).to eq(team)
        expect(json["role"]).to eq(@role_one)
      end
    end

    context "without parameters" do
      it "returns bad request" do
        post "/memberships", params: {}
        json = JSON.parse(response.body)

        expect(response).to have_http_status(:bad_request)
        expect(json["errors"]).not_to be_empty
      end
    end

    context "with an unknown user_id" do
      it "returns bad request" do
        post "/memberships", params: { user_id: "unknown", team_id: team }
        json = JSON.parse(response.body)

        expect(response).to have_http_status(:bad_request)
        expect(json["errors"]).not_to be_empty
        expect(json["errors"].first).to eq("The user_id is not associated with the given team_id")
      end
    end

    context "with an unknown team_id" do
      let(:team) { "unknown" }

      before do
        stub_request(:get, "#{service_uri}/teams/#{team}")
          .to_return(status: 200, body: "null")
      end

      it "returns bad request" do
        post "/memberships", params: { user_id: user_three, team_id: team }
        json = JSON.parse(response.body)

        expect(response).to have_http_status(:bad_request)
        expect(json["errors"]).not_to be_empty
        expect(json["errors"][0]).to eq("Couldn't find the team referenced by the given team_id")
      end
    end      

    context "with an unknown role_id" do
      it "returns not found" do
        post "/memberships", params: { user_id: user_three, team_id: team, role_id: "unknown" }
        json = JSON.parse(response.body)

        expect(response).to have_http_status(:not_found)
        expect(json["errors"]).not_to be_empty
        expect(json["errors"].first).to eq("Role not found")
      end
    end    
  end

end
