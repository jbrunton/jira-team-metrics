require 'securerandom'

module JiraTeamMetrics::ApplicationHelper
  include JiraTeamMetrics::FormattingHelper
  include JiraTeamMetrics::LinkHelper
  include JiraTeamMetrics::ChartsHelper
  include JiraTeamMetrics::PathHelper
  include JiraTeamMetrics::HtmlHelper
  include JiraTeamMetrics::EnvironmentHelper
  include JiraTeamMetrics::OrderingHelper

  def generate_id
    SecureRandom.urlsafe_base64(10)
  end
end