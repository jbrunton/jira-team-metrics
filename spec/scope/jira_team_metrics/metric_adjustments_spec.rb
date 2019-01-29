require 'rails_helper'

RSpec.describe JiraTeamMetrics::MetricAdjustments do
  YAML_STRING = <<~END
    and:
      throughput: 2.0
      issues_per_epic: 4.0
    ios:
      adjust_throughput_by: 0.75
      adjust_issues_per_epic_by: 0.5
    api:
      adjust_throughput_by: 75%
      adjust_issues_per_epic_by: 150%
  END

  VALID_YAML_INVALID_VALUE = <<~END
    and:
      throughput: noice!
      issues_per_epic: 4.0
  END

  INVALID_YAML = <<~END
    and
      throughput 4
      issues_per_epic 4.0
  END

  let(:metric_adjustments) { JiraTeamMetrics::MetricAdjustments.parse(YAML_STRING) }

  describe ".parse" do
    it "parses percentages" do
      expect(metric_adjustments.adjusted_throughput('api', 4.0)).to eq(3.0)
    end

    it "silently ignores syntax errors in values" do
      metric_adjustments = JiraTeamMetrics::MetricAdjustments.parse(VALID_YAML_INVALID_VALUE)
      expect(metric_adjustments.adjusted_epic_scope('and', 5.0)).to eq(4.0)
      expect(metric_adjustments.adjusted_throughput('and', 5.0)).to eq(nil)
    end

    it "silently ignores invalid string inputs" do
      metric_adjustments = JiraTeamMetrics::MetricAdjustments.parse(INVALID_YAML)
      expect(metric_adjustments.adjusted_epic_scope('and', 5.0)).to eq(nil)
    end
  end

  describe "#adjusted_epic_scope" do
    it "returns the adjusted issues per epic for the team" do
      expect(metric_adjustments.adjusted_epic_scope('and', 5.0)).to eq(4.0)
    end
  end

  describe "#adjusted_throughput" do
    it "returns the adjusted throughput for the team" do
      expect(metric_adjustments.adjusted_throughput('ios', 4.0)).to eq(3.0)
    end
  end
end