require 'rails_helper'

RSpec.describe TeamClient do
  subject { described_class.fetch_team(param)}
  let(:base_uri) { ENV.fetch('TEAM_SERVICE_URI') }

  describe ".fetch_team" do

    context "with a valid team_id" do
      let(:param) { "test" }
      let(:response) do
        {
          id: "test",
          name: "test",
          teamLeadId: "1",
          teamMemberIds: ["2","3"]
        }
      end

      before do
        stub_request(:get, "#{base_uri}/teams/#{param}")
          .to_return(status: 200, body: response.to_json, headers: {})
      end

      it "retrieves team information" do
        expect(subject).to be_a(TeamClient)
        expect(subject.users).to eq(["1", "2", "3"])
      end
    end

    context "with an invalid team_id" do
      let(:param) { "test" }
      let(:response) { "null" }

      before do
        stub_request(:get, "#{base_uri}/teams/#{param}")
          .to_return(status: 200, body: "null", headers: {})
      end

      it "raises an exception" do
        expect { subject }.to raise_error(App::ClientError)
      end      
    end
  end
end