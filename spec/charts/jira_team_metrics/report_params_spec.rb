require 'rails_helper'

RSpec.describe JiraTeamMetrics::ReportParams do
  let(:board) { create(:board) }
  let(:from_date) { '2018-06-01' }
  let(:to_date) { '2018-07-01' }
  let(:query) { 'some query' }
  let(:filter) { 'My Filter' }
  let(:hierarchy_level) { 'Scope' }
  let(:step_interval) { 'Weekly' }
  let(:team) { 'My Team' }

  describe "#initialize" do
    it "sets default values if not given" do
      report_params = JiraTeamMetrics::ReportParams.new(board, {})
      expect(report_params.hierarchy_level).to eq('Scope')
      expect(report_params.step_interval).to eq('Daily')
    end
  end

  describe ".from_params" do
    it "returns an instance built from the given request params" do
      report_params = JiraTeamMetrics::ReportParams.from_params(board, {
        from_date: from_date,
        to_date: to_date,
        query: query,
        filter: filter,
        hierarchy_level: hierarchy_level,
        step_interval: step_interval,
        team: team
      })

      expect(report_params.date_range).to eq(JiraTeamMetrics::DateRange.new(
        DateTime.parse(from_date),
        DateTime.parse(to_date)
      ))
      expect(report_params.query).to eq(query)
      expect(report_params.filter).to eq(filter)
      expect(report_params.hierarchy_level).to eq(hierarchy_level)
      expect(report_params.step_interval).to eq(step_interval)
      expect(report_params.team).to eq(team)
    end
  end

  describe "#to_query" do
    it "builds an mql query based on the params" do
      report_params = JiraTeamMetrics::ReportParams.from_params(board, {
        from_date: from_date,
        to_date: to_date,
        query: query,
        filter: filter,
        hierarchy_level: hierarchy_level,
        step_interval: step_interval,
        team: team
      })
      expect(report_params.to_query).to eq("((some query) and (filter('My Filter'))) and (hierarchyLevel = 'Scope')")
    end
  end
end