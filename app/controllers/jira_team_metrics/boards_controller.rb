class JiraTeamMetrics::BoardsController < JiraTeamMetrics::ApplicationController
  include JiraTeamMetrics::ApplicationHelper

  before_action :set_domain
  before_action :set_board, only: [:show, :update, :sync]

  def show
    today = DateTime.now.beginning_of_day
    @issue_cycletimes_ql = issue_cycletimes_ql(today)
    @epic_cycletimes_ql = epic_cycletimes_ql(today)
    @issue_throughput_ql = issue_throughput_ql(today)
    @epic_throughput_ql = epic_throughput_ql(today)
    @issues_cfd_ql = issues_cfd_ql(today)
    @epics_cfd_ql = epics_cfd_ql(today)
  end

  def search
    @boards = JiraTeamMetrics::Board.search(params[:query]).first(20)
    render json: @boards.map{ |board| board.as_json.merge(link: board_path( board)) }
  end

  def update
    @domain.with_lock do
      if JiraTeamMetrics::ModelUpdater.new(@board).update(board_params)
        render json: {}, status: :ok
      else
        render partial: 'partials/config_form', status: 400
      end
    end
  end

  def sync
    @credentials = env_credentials || JiraTeamMetrics::Credentials.new(credentials_params)
    @domain.with_lock do
      if JiraTeamMetrics::ModelUpdater.new(@board).can_sync?(@credentials) && @credentials.valid?
        @domain.syncing = true
        @domain.save!
        JiraTeamMetrics::SyncBoardJob.perform_later(@board.jira_id, @board.domain, @credentials.to_serializable_hash, sync_months)
        render json: {}, status: 200
      else
        render partial: 'partials/sync_form', status: 400
      end
    end
  end

private
  def credentials_params
    params.require(:credential).permit(:username, :password)
  end

  def sync_months
    months = params.permit(:months)[:months]
    months.blank? ? nil : months.to_i
  end

  def board_params
    params.require(:board).permit(:config_string)
  end

  def issue_cycletimes_ql(today)
    JiraTeamMetrics::QuicklinkBuilder.new(report_name: 'scatterplot', hierarchy_level: 'Scope')
      .set_defaults(today)
      .build_for(@board)
  end

  def epic_cycletimes_ql(today)
    JiraTeamMetrics::QuicklinkBuilder.new(report_name: 'scatterplot', hierarchy_level: 'Epic')
      .set_defaults(today)
      .build_for(@board)
  end

  def issue_throughput_ql(today)
    JiraTeamMetrics::QuicklinkBuilder.new(report_name: 'throughput', hierarchy_level: 'Scope')
      .set_defaults(today)
      .build_for(@board)
  end

  def epic_throughput_ql(today)
    JiraTeamMetrics::QuicklinkBuilder.new(report_name: 'throughput', hierarchy_level: 'Epic')
      .set_defaults(today)
      .build_for(@board)
  end

  def issues_cfd_ql(today)
    JiraTeamMetrics::QuicklinkBuilder.new(report_name: 'cfd', hierarchy_level: 'Scope')
      .set_defaults(today)
      .build_for(@board)
  end

  def epics_cfd_ql(today)
    JiraTeamMetrics::QuicklinkBuilder.new(report_name: 'cfd', hierarchy_level: 'Epic')
      .set_defaults(today)
      .build_for(@board)
  end
end