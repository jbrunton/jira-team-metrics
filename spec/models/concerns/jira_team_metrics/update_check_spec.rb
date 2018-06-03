require 'rails_helper'

RSpec.describe JiraTeamMetrics::UpdateCheck do
  let(:domain) { create(:domain) }
  let(:board) { domain.boards.create(attributes_for(:board)) }
  let(:check) { JiraTeamMetrics::UpdateCheck.new(board) }

  describe "#can_update" do
    context "if the model isn't syncing" do
      before(:each) { domain.syncing = false }

      it "returns true" do
        expect(check.can_update?).to eq(true)
      end
    end

    context "if the model is syncing" do
      before(:each) { domain.syncing = true }

      it "returns false" do
        expect(check.can_update?).to eq(false)
      end

      it "adds an error message to the instance if no target_model is given" do
        check.can_update?
        expect(board.errors[:base]).to eq(["Synchronize job in progress, please wait."])
      end

      it "adds an error message to the target_model if given" do
        target_model = Class.new { include ActiveModel::Model }.new
        check.can_update?(target_model)
        expect(target_model.errors[:base]).to eq(["Synchronize job in progress, please wait."])
      end
    end

    context "if READONLY is nil" do
      before(:each) {
        allow(ENV).to receive(:[]).with('READONLY').and_return(nil)
      }

      it "returns true" do
        expect(check.can_update?).to eq(true)
      end
    end

    context "if READONLY is 1" do
      before(:each) { allow(ENV).to receive(:[]).with('READONLY').and_return(1) }

      it "returns false" do
        expect(check.can_update?).to eq(false)
      end

      it "adds an error message to the instance if no target_model is given" do
        check.can_update?
        expect(board.errors[:base]).to eq(["Server started in readonly mode. Config is readonly."])
      end

      it "adds an error message to the target_model if given" do
        target_model = Class.new { include ActiveModel::Model }.new
        check.can_update?(target_model)
        expect(target_model.errors[:base]).to eq(["Server started in readonly mode. Config is readonly."])
      end
    end
  end
end