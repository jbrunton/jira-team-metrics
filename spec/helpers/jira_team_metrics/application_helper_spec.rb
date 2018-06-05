require 'rails_helper'

RSpec.describe JiraTeamMetrics::ApplicationHelper do
  describe "#readonly?" do
    it "returns true if READONLY is set" do
      allow(ENV).to receive(:[]).with('READONLY').and_return(1)
      expect(helper.readonly_mode?).to eq(true)
    end

    it "returns false otherwise" do
      expect(helper.readonly_mode?).to eq(false)
    end
  end
end
