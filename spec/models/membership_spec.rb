require 'rails_helper'

RSpec.describe Membership, type: :model do
  let(:user_id) { SecureRandom.uuid }
  let(:team_id) { SecureRandom.uuid }

  before do
    @default_role = Role.create!(name: "first (default)", is_default: true)
    @second_role = Role.create!(name: "second", is_default: false)
    @third_role = Role.create!(name: "third", is_default: false)
  end

  describe "#save!" do

    context "with no explicit role" do
      subject { described_class.new(user_id:, team_id:) }
      
      it "persists to database" do
        expect { subject.save! }.to change { Membership.count }.by(1)
      end

      it "assigns default role to new record" do
        subject.save!
        expect(subject.role.id).to eq(@default_role.id)
      end
    end

    context "with a repeated user_id for the same team" do
      subject { described_class.new(user_id:, team_id:) }

      before do
        Membership.create!(user_id:, team_id:)
      end

      it "raises an exception" do
        expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "with required parameters absent" do
      subject { described_class.new }

      it "raises an exception" do
        expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "with all valid parameters" do
      let(:role) { @second_role }
      subject { described_class.new(user_id:, team_id:, role:) }

      it "persists to database" do
        expect { subject.save! }.to change { Membership.count }.by(1)
      end
    end

  end
end