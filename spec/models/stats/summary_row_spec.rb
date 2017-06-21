RSpec.describe SummaryRow do
  let(:issues) {
    [
      IssueDecorator.new(TestIssue.new({'issue_type' => 'Story'}, 1.0), nil, nil),
      IssueDecorator.new(TestIssue.new({'issue_type' => 'Story'}, 6.0), nil, nil),
      IssueDecorator.new(TestIssue.new({'issue_type' => 'Story'}, 8.0), nil, nil),
      IssueDecorator.new(TestIssue.new({'issue_type' => 'Bug'}, 1.0), nil, nil)
    ]
  }

  let(:summary_row) {
    SummaryRow.new(issues, 'Story')
  }

  describe "#issue_type" do
    it "returns the issue_type" do
      expect(summary_row.issue_type).to eq('Story')
    end
  end

  describe "#count" do
    it "returns the count of issues of the given type" do
      expect(summary_row.count).to eq(3)
    end
  end

  describe "#count_percentage" do
    it "returns the percent of issues of the given type" do
      expect(summary_row.count_percentage).to eq(75.0)
    end
  end

  describe "ct_mean" do
    it "returns the mean cycle time" do
      expect(summary_row.ct_mean).to eq(5.0)
    end
  end

  describe "ct_median" do
    it "returns the median cycle time" do
      expect(summary_row.ct_median).to eq(6.0)
    end
  end

  describe "ct_stddev" do
    it "returns the stddev of the cycle time" do
      expect(summary_row.ct_stddev).to eq(2.943920288775949)
    end
  end

  class TestIssue < Issue
    def initialize(attrs, cycle_time)
      super(attrs)
      @cycle_time = cycle_time
    end

    def cycle_time
      @cycle_time
    end
  end
end
