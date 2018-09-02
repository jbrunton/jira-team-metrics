require 'rails_helper'

RSpec.describe JiraTeamMetrics::StatusNotifier do
  let(:domain) { create(:domain) }
  let(:board) { create(:board, domain: domain) }
  let(:status_title) { 'syncing' }

  context "when given a domain" do
    let(:notifier) { JiraTeamMetrics::StatusNotifier.new(domain, status_title) }

    describe "#notify_status" do
      let(:status) { '10% complete' }

      it "broadcasts a status message to the domain" do
        expected_message = {
          in_progress: true,
          status: status,
          statusTitle: status_title
        }
        expect(ActionCable.server).to receive(:broadcast).with('sync_domain', expected_message)
        notifier.notify_status(status)
      end
    end

    describe "#notify_complete" do
      it "broadcasts a completion message" do
        expected_message = {
          in_progress: false
        }
        expect(ActionCable.server).to receive(:broadcast).with('sync_domain', expected_message)
        notifier.notify_complete
      end
    end

    describe "#notify_error" do
      let(:error) { 'There was an error' }

      context "when no error code is given" do
        it "broadcasts an error to the domain" do
          expected_message = {
            in_progress: false,
            error: error
          }
          expect(ActionCable.server).to receive(:broadcast).with('sync_domain', expected_message)
          notifier.notify_error(error)
        end
      end

      context "when an error code is given" do
        let(:error_code) { 401 }

        it "broadcasts an error to the domain" do
          expected_message = {
            in_progress: false,
            error: error,
            errorCode: error_code
          }
          expect(ActionCable.server).to receive(:broadcast).with('sync_domain', expected_message)
          notifier.notify_error(error, error_code)
        end
      end
    end

    describe "#notify_progress" do
      let(:status) { '10% complete' }
      let(:progress) { 65 }

      it "broadcasts a progress message to the domain" do
        expected_message = {
          in_progress: true,
          status: status,
          statusTitle: status_title,
          progress: progress
        }
        expect(ActionCable.server).to receive(:broadcast).with('sync_domain', expected_message)
        notifier.notify_progress(status, progress)
      end
    end
  end

  context "when given a board" do
    let(:notifier) { JiraTeamMetrics::StatusNotifier.new(board, status_title) }
    let(:status) { '10% complete' }

    it "broadcasts messages to the board and the domain" do
      expected_message = {
        in_progress: true,
        status: status,
        statusTitle: status_title
      }
      expect(ActionCable.server).to receive(:broadcast).with('sync_domain', expected_message)
      expect(ActionCable.server).to receive(:broadcast).with("sync_board_#{board.jira_id}", expected_message)
      notifier.notify_status(status)
    end

    context "if the domain is inactive" do
      before(:each) { domain.active = false }

      it "only sends the completion event to the board" do
        expected_message = {
          in_progress: false
        }
        expect(ActionCable.server).to receive(:broadcast).with("sync_board_#{board.jira_id}", expected_message)
        notifier.notify_complete
      end
    end
  end
end