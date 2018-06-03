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

  def generate_id
    SecureRandom.urlsafe_base64(10)
  end
end