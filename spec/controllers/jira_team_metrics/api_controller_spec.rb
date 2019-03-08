require 'rails_helper'

RSpec.describe JiraTeamMetrics::ApiController, type: :controller do
  routes { JiraTeamMetrics::Engine.routes }

  include JiraTeamMetrics::PathHelper

  let!(:domain) { create(:domain) }
  let!(:board) { domain.boards.create(attributes_for(:board, name: 'My Board')) }
  let!(:issue) { create(:issue, board: board, key: 'ISSUE-123') }

  describe "GET #query" do
    it "returns the json for the query" do
      query = "select key from scope() where key = 'ISSUE-123'"

      get :query, params: {board_id: board.jira_id, format: 'json', query: query}

      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json['data']).to eq({
        'cols' => [{ 'label' => 'key', 'type' => 'string' }],
        'rows' => [{ 'c' => [{ 'v' => 'ISSUE-123' }] }]
      })
    end
  end
end
