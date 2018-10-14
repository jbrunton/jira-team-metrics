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
    @credentials = JiraTeamMetrics::Credentials.new(credentials_params)
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
    opts = ql_cycletimes_opts(today, 30, hierarchy_level: 'Scope')
    ql_report_path('scatterplot', opts)
  end

  def epic_cycletimes_ql(today)
    opts = ql_cycletimes_opts(today, 90, hierarchy_level: 'Epic')
    ql_report_path('scatterplot', opts)
  end

  def issue_throughput_ql(today)
    opts = ql_throughput_opts(today, hierarchy_level: 'Scope')
    ql_report_path('throughput', opts)
  end

  def epic_throughput_ql(today)
    opts = ql_throughput_opts(today, hierarchy_level: 'Epic')
    ql_report_path('throughput', opts)
  end

  def ql_report_path(report_name, opts)
    "#{reports_path(@board)}/#{report_name}?#{opts.to_query}"
  end

  def ql_cycletimes_opts(today, days, opts)
    to_date = today
    from_date = to_date - days
    opts.merge({
      from_date: format_mql_date(from_date),
      to_date: format_mql_date(to_date)
    })
  end

  def ql_throughput_opts(today, opts)
    to_date = today.at_beginning_of_month
    from_date = to_date - 6.months
    opts.merge({
      from_date: format_mql_date(from_date),
      to_date: format_mql_date(to_date),
      step_interval: 'Monthly'
    })
  end
end