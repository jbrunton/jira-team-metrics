class JiraTeamMetrics::DomainsController < JiraTeamMetrics::ApplicationController
  before_action :set_domain
  include JiraTeamMetrics::ApplicationHelper

  def show
    @boards = @domain.boards.select do |board|
      !board.last_synced.nil?
    end
  end

  def update
    if readonly?
      render_unauthorized
    elsif syncing?(@domain)
      render_syncing
    elsif @domain.update(domain_params)
      render json: {}, status: :ok
    else
      render partial: 'partials/config_form', status: 400
    end
  end

  def sync
    @credentials = JiraTeamMetrics::Credentials.new(credentials_params)
    if syncing?(@domain)
      render_syncing
    elsif @credentials.valid?
      JiraTeamMetrics::SyncDomainJob.perform_later(@domain, @credentials.to_serializable_hash)
      render json: {}, status: 200
    else
      render partial: 'partials/sync_form', status: 400
    end
  end

  def metadata

  end

private
  def domain_params
    params.require(:domain).permit(:name, :url, :config_string)
  end

  def credentials_params
    params.require(:credential).permit(:username, :password)
  end
end
