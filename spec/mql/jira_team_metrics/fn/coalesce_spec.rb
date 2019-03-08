require 'rails_helper'

RSpec.describe JiraTeamMetrics::Fn::Coalesce do
  it "coalesces values" do
    fn = JiraTeamMetrics::Fn::Coalesce.new
    result = fn.call(nil, nil, 1)
    expect(result).to eq(1)
  end
end