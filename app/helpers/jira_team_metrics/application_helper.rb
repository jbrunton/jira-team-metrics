require 'securerandom'

module JiraTeamMetrics::ApplicationHelper
  include JiraTeamMetrics::FormattingHelper
  include JiraTeamMetrics::LinkHelper
  include JiraTeamMetrics::ChartsHelper
  include JiraTeamMetrics::PathHelper
  include JiraTeamMetrics::HtmlHelper

  def readonly?
    !!ENV['READONLY']
  end

  def syncing?(object)
    return false if object.nil?

    if object.class == JiraTeamMetrics::Board
      object.transaction { object.syncing }
    elsif object.class == JiraTeamMetrics::Domain
      object.transaction do
        object.syncing || object.boards.any? { |board| board.syncing }
      end
    end
  end

  def generate_id
    SecureRandom.urlsafe_base64(10)
  end
end