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
    @board.transaction do
      if readonly?
        render_unauthorized
      elsif @board.update(board_params)
        render json: {}, status: :ok
      else
        render partial: 'partials/config_form', status: 400
      end
    end
  end

  def sync
    @board.transaction do
      @credentials = JiraTeamMetrics::Credentials.new(credentials_params)
      if @board.valid? && @credentials.valid?
        JiraTeamMetrics::SyncBoardJob.perform_later(@board, @credentials.to_serializable_hash, sync_months)
        render json: {}, status: 200
      else
        @board.errors[:base].each { |e| @credentials.errors.add(:base, e) }
        render partial: 'partials/sync_form', status: 400
      end
    end
  end

private
  def credentials_params
    params.require(:credential).permit(:username, :password)
  end

  def subquery
    params.permit(:subquery)[:subquery]
  end

  def sync_months
    months = params.permit(:months)[:months]
    months.blank? ? nil : months.to_i
  end

  def board_params
    params.require(:board).permit(:config_string)
  end
end