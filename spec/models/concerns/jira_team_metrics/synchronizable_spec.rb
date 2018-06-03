require 'rails_helper'

RSpec.describe JiraTeamMetrics::Synchronizable do
  let(:instance) do
    Class.new do
      include JiraTeamMetrics::Synchronizable
      include ActiveModel::Model
    end.new
  end

  describe "#validate_syncing" do
    context "if the model isn't syncing" do
      before(:each) { instance.define_singleton_method(:sync_in_progress?) { false } }

      it "returns true" do
        expect(instance.validate_syncing).to eq(true)
      end
    end

    context "if the model is syncing" do
      before(:each) { instance.define_singleton_method(:sync_in_progress?) { true } }

      it "returns false" do
        expect(instance.validate_syncing).to eq(false)
      end

      it "adds an error message to the instance if no target_model is given" do
        instance.validate_syncing
        expect(instance.errors[:base]).to eq(["Synchronize job in progress, please wait."])
      end

      it "adds an error message to the target_model if given" do
        target_model = Class.new { include ActiveModel::Model }.new
        instance.validate_syncing(target_model)
        expect(target_model.errors[:base]).to eq(["Synchronize job in progress, please wait."])
      end
    end
  end
end