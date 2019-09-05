require 'rails_helper'

RSpec.describe JiraTeamMetrics::QuicklinkBuilder do
  include JiraTeamMetrics::PathHelper
  include JiraTeamMetrics::Engine.routes.url_helpers

  let(:board) { create(:board) }
  let(:today) { DateTime.new(2018, 10, 16) }

  describe "#build_for" do
    it "builds default scatterplot reports" do
      builder = JiraTeamMetrics::QuicklinkBuilder.new(report_name: 'scatterplot', hierarchy_level: 'Scope')
          .set_defaults(today)

      uri = URI(builder.build_for(board))

      expect(uri.path).to eq("#{reports_path(board)}/scatterplot")
      params = Rack::Utils.parse_nested_query(uri.query)
      expect(params).to eq({
          'from_date' => '2018-09-16',
          'to_date' => '2018-10-16',
          'hierarchy_level' => 'Scope'
      })
    end

    it "builds default throughput reports" do
      builder = JiraTeamMetrics::QuicklinkBuilder.new(report_name: 'throughput', hierarchy_level: 'Scope')
          .set_defaults(today)

      uri = URI(builder.build_for(board))

      expect(uri.path).to eq("#{reports_path(board)}/throughput")
      params = Rack::Utils.parse_nested_query(uri.query)
      expect(params).to eq({
          'from_date' => '2018-04-01',
          'to_date' => '2018-10-01',
          'step_interval' => 'Monthly',
          'hierarchy_level' => 'Scope'
      })
    end

    it "builds default cfd reports" do
      builder = JiraTeamMetrics::QuicklinkBuilder.new(report_name: 'cfd', hierarchy_level: 'Scope')
        .set_defaults(today)

      uri = URI(builder.build_for(board))

      expect(uri.path).to eq("#{reports_path(board)}/cfd")
      params = Rack::Utils.parse_nested_query(uri.query)
      expect(params).to eq({
        'from_date' => '2018-09-16',
        'to_date' => '2018-10-16',
        'hierarchy_level' => 'Scope'
      })
    end
  end
end
