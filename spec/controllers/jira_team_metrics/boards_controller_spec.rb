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

  describe "POST #update" do
    context "with valid params" do
      let(:new_attributes) {
        { config_string: "sync:\n  months: 6" }
      }

      it "updates the board" do
        post :update, params: {:board_id => board.jira_id, :board => new_attributes}
        board.reload
        expect(board.config.sync_months).to eq(6)
      end

      it "returns a 200" do
        post :update, params: {:board_id => board.jira_id, :board => new_attributes}
        expect(response.status).to eq(200)
      end
    end

    context "with invalid params" do
      let(:new_attributes) {
        { config_string: "sync:\n  months: 6\ninvalid: attribute" }
      }

      it "doesn't update the board" do
        post :update, params: {:board_id => board.jira_id, :board => new_attributes}
        expect(board.config.sync_months).to eq(nil)
      end

      it "re-renders the 'config' template" do
        post :update, params: {:board_id => board.jira_id, :board => new_attributes}
        expect(response).to render_template('partials/_config_form')
        expect(response.status).to eq(400)
      end
    end

    context "if the app is in readonly mode" do
      let(:new_attributes) {
        { config_string: "sync:\n  months: 6" }
      }

      before(:each) { allow(ENV).to receive(:[]).with('READONLY').and_return(1) }

      it "doesn't update the board" do
        post :update, params: {:board_id => board.jira_id, :board => new_attributes}
        expect(board.config.sync_months).to eq(nil)
      end

      it "re-renders the 'config' template" do
        post :update, params: {:board_id => board.jira_id, :board => new_attributes}
        expect(response).to render_template('partials/_config_form')
        expect(response.status).to eq(400)
      end
    end

    context "if the domain is syncing" do
      let(:new_attributes) {
        { config_string: "sync:\n  months: 6" }
      }

      before(:each) {
        domain.syncing = true
        domain.save
      }

      it "doesn't update the board" do
        post :update, params: {:board_id => board.jira_id, :board => new_attributes}
        expect(board.config.sync_months).to eq(nil)
      end

      it "re-renders the 'config' template" do
        post :update, params: {:board_id => board.jira_id, :board => new_attributes}
        expect(response).to render_template('partials/_config_form')
        expect(response.status).to eq(400)
      end
    end
  end
end
