require 'rails_helper'

RSpec.describe JiraTeamMetrics::ChartParams do
  let(:from_date) { '2018-06-01' }
  let(:to_date) { '2018-07-01' }
  let(:query) { 'some query' }
  let(:filter) { 'My Filter' }
  let(:hierarchy_level) { 'Scope' }
  let(:team) { 'My Team' }

  describe ".from_params" do
    it "returns an instance built from the given request params" do
      chart_params = JiraTeamMetrics::ChartParams.from_params({
        from_date: from_date,
        to_date: to_date,
        query: query,
        filter: filter,
        hierarchy_level: hierarchy_level,
        team: team
      })

      expect(chart_params.date_range).to eq(JiraTeamMetrics::DateRange.new(
        DateTime.parse(from_date),
        DateTime.parse(to_date)
      ))
      expect(chart_params.query).to eq(query)
      expect(chart_params.filter).to eq(filter)
      expect(chart_params.hierarchy_level).to eq(hierarchy_level)
      expect(chart_params.team).to eq(team)
    end
  end

  describe "#to_query" do
    it "builds an mql query based on the params" do
      chart_params = JiraTeamMetrics::ChartParams.from_params({
        from_date: from_date,
        to_date: to_date,
        query: query,
        filter: filter,
        hierarchy_level: hierarchy_level,
        team: team
      })
      expect(chart_params.to_query).to eq("((some query) and (filter = 'My Filter')) and (hierarchyLevel = 'Scope')")
    end
  end
end