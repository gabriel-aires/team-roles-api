require 'rails_helper'

RSpec.describe Role, type: :model do

  describe "#save!" do

    context "with a clean database" do

      context "with an implicit is_default value" do
        subject { described_class.new(name: "test") }

        it "raises an exception" do
          expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end

      context "with is_default set to false" do
        subject { described_class.new(name: "test", is_default: false) }

        it "raises an exception" do
          expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end

      context "with is_default set to true" do
        subject { described_class.new(name: "test", is_default: true) }

        it "persists to database" do
          expect { subject.save! }.to change { Role.count }.by(1)
        end
      end

    end

    context "with an existing default role" do
      let(:name) { "previous_default" }

      before do
        Role.create!(name:, is_default: true)
      end

      context "with is_default set to false" do
        subject { described_class.new(name: "test", is_default: false) }

        it "persists to database" do
          expect { subject.save! }.to change { Role.count }.by(1)
        end

        it "keeps the previous default rule" do
          expect { subject.save! }.not_to change { Role.find_by(name:).is_default }
        end
      end

      context "with is_default set to true" do
        subject { described_class.new(name: "test", is_default: true) }

        it "persists to database" do
          expect { subject.save! }.to change { Role.count }.by(1)
        end

        it "changes the previous default into a regular rule" do
          expect { subject.save! }.to change { Role.find_by(name:).is_default }
        end
      end

      context "with the same name" do
        subject { described_class.new(name:, is_default: false) }

        it "raises an exception" do
          expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end

    context "without a name" do
      subject { described_class.new(is_default: true) }

      it "raises an exception" do
        expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

end
