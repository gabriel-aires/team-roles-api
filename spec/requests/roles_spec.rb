require 'rails_helper'

RSpec.describe "Roles", type: :request do
  before do
    role_params = { name: "Developer", is_default: true }
    post "/roles", params: role_params
    @role = JSON.parse(response.body)
  end

  describe "GET /roles" do
    it "returns all roles" do
      get "/roles"
      json = JSON.parse(response.body)

      expect(response).to have_http_status(:success)
      expect(json.size).to eq(1)
      expect(json.first).to eq(@role)
    end
  end

  describe "GET /roles/:id" do
    context "with an existing id" do
      let(:id) { @role["id"] }

      it "returns a role" do
        get "/roles/#{id}"
        json = JSON.parse(response.body)

        expect(response).to have_http_status(:success)
        expect(json).to eq(@role)
      end
    end

    context "with a unknown id" do
      let(:id) { 0 }

      it "returns not found" do
        get "/roles/#{id}"
        json = JSON.parse(response.body)

        expect(response).to have_http_status(:not_found)
        expect(json["errors"]).not_to be_empty
        expect(json["errors"].first).to eq("Role not found")
      end
    end
  end

  describe "POST /roles" do
    context "with valid params" do
      let(:params) { { name: "test", is_default: false } }

      it "creates a role" do
        expect { post "/roles", params: params }.to change { Role.count }.by(1)

        json = JSON.parse(response.body)

        expect(response).to have_http_status(:created)
        expect(json["id"]).not_to be_nil
        expect(json["name"]).to eq("test")
        expect(json["is_default"]).to eq(false)
      end
    end

    context "with missing params" do
      let(:params) { {} }

      it "returns validation errors" do
        post "/roles", params: params

        json = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["errors"]).not_to be_empty
      end
    end
  end

end
