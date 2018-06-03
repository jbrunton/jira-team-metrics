require 'rails_helper'

RSpec.describe JiraTeamMetrics::BoardsController, type: :controller do
  routes { JiraTeamMetrics::Engine.routes }

  include JiraTeamMetrics::PathHelper

  let!(:domain) { create(:domain) }
  let!(:board) { domain.boards.create(attributes_for(:board, name: 'My Board')) }

  describe "GET #show" do
    it "assigns the requested board as @board" do
      get :show, params: {board_id: board.jira_id}
      expect(assigns(:board)).to eq(board)
    end

    it "renders boards/show template" do
      get :show, params: {board_id: board.jira_id}
      expect(response).to render_template('boards/show')
    end
  end

  describe "GET #search" do
    let!(:another_board) { domain.boards.create(attributes_for(:board, name: 'Another Board')) }

    it "searches for all boards matching the query" do
      get :search, params: {query: 'Board'}
      expect(assigns(:boards)).to eq([board, another_board])
    end

    it "excludes boards not matching the query" do
      get :search, params: {query: 'My Board'}
      expect(assigns(:boards)).to eq([board])
    end
  end
end
