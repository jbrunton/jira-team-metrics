class JiraTeamMetrics::DomainsController < JiraTeamMetrics::ApplicationController
  before_action :set_domain
  include JiraTeamMetrics::ApplicationHelper

  def show
    @boards = @domain.boards.where(active: true).select do |board|
      !board.last_synced.nil?
    end
  end

  def update
    @domain.with_lock do
      if JiraTeamMetrics::ModelUpdater.new(@domain).update(domain_params)
        render json: {}, status: :ok
      else
        render partial: 'partials/config_form', status: 400
      end
    end
  end

  def sync
    @credentials = env_credentials || JiraTeamMetrics::Credentials.new(credentials_params)
    @domain.with_lock do
      if JiraTeamMetrics::ModelUpdater.new(@domain).can_sync?(@credentials) && @credentials.valid?
        @domain.syncing = true
        @domain.save!
        JiraTeamMetrics::SyncDomainJob.perform_later(@credentials.to_serializable_hash)
        render json: {}, status: 200
      else
        render partial: 'partials/sync_form', status: 400
      end
    end
  end

  def metadata
  end

  def sync_history
    @sync_histories = JiraTeamMetrics::SyncHistory
      .where('started_time is not null AND completed_time is not null')
      .where('created_at >= ?', DateTime.now.to_date - 7.days)
      .order('coalesce(sync_history_id, id) DESC', 'created_at ASC')
  end

private
  def domain_params
    params.require(:domain).permit(:name, :url, :config_string)
  end

  def credentials_params
    params.require(:credential).permit(:username, :password)
  end
end
