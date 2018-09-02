require 'rails_helper'

RSpec.describe JiraTeamMetrics::HttpErrorHandler do
  let(:notifier) { instance_double('JiraTeamMetrics::StatusNotifier') }
  let(:error_handler) { JiraTeamMetrics::HttpErrorHandler.new(notifier) }

  describe "#invoke" do
    context "when the block raises a Timeout::Error" do
      it "notifies of a time out" do
        expect(notifier).to receive(:notify_error).with('connection timed out')
        expect {
          error_handler.invoke { raise Timeout::Error }
        }.to raise_error(Timeout::Error)
      end
    end

    context "when the block raises an http error" do
      it "notifies of the error" do
        expect(notifier).to receive(:notify_error).with('Could not find page', nil)
        expect {
          error_handler.invoke { raise Net::HTTPBadResponse.new('Could not find page') }
        }.to raise_error(Net::HTTPBadResponse)
      end
    end
  end
end