class JiraTeamMetrics::DomainsController < JiraTeamMetrics::ApplicationController
  before_action :set_domain
  include JiraTeamMetrics::ApplicationHelper

  def show
    @boards = @domain.boards.select do |board|
      !board.last_synced.nil?
    end
  end

  def update
    @domain.transaction do
      if @domain.validate_syncing && @domain.update(domain_params)
        render json: {}, status: :ok
      else
        render partial: 'partials/config_form', status: 400
      end
    end
  end

  def sync
    @domain.transaction do
      @credentials = JiraTeamMetrics::Credentials.new(credentials_params)
      if @domain.validate_syncing(@credentials) && @credentials.valid?
        JiraTeamMetrics::SyncDomainJob.perform_later(@domain, @credentials.to_serializable_hash)
        render json: {}, status: 200
      else
        render partial: 'partials/sync_form', status: 400
      end
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
