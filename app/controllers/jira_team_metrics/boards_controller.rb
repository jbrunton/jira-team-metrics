class JiraTeamMetrics::BoardsController < JiraTeamMetrics::ApplicationController
  include JiraTeamMetrics::ApplicationHelper

  before_action :set_domain
  before_action :set_board, only: [:show, :update, :sync]

  def show
  end

  def search
    @boards = JiraTeamMetrics::Board.where('name LIKE ?', "%#{params[:query]}%")
    respond_to do |format|
      format.json { render json: @boards.map{ |board| board.as_json.merge(link: board_path( board)) } }
    end
  end

  def update
    if readonly?
      render_unauthorized
    elsif @board.update(board_params)
      render json: {}, status: :ok
    else
      render partial: 'config_form', status: 400
    end
  end

  def sync
    @credentials = JiraTeamMetrics::Credentials.new(credentials_params)
    if @credentials.valid?
      JiraTeamMetrics::SyncBoardJob.perform_later(@board.object, @credentials.username, @credentials.password, subquery, since)
      render json: {}, status: 200
    else
      render partial: 'partials/sync_form', status: 400
    end
  end

private
  def credentials_params
    params.require(:credential).permit(:username, :password)
  end

  def subquery
    params.permit(:subquery)[:subquery]
  end

  def since
    params.permit(:since)[:since]
  end

  def board_params
    params.require(:board).permit(:config_string)
  end
end