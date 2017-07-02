class BoardsController < ApplicationController
  include ApplicationHelper

  before_action :set_domain
  before_action :set_board

  def show
    @credentials = Credentials.new
  end

  def search
    @boards = Board.where('name LIKE ?', "%#{params[:query]}%")
    respond_to do |format|
      format.json { render json: @boards.map{ |board| board.as_json.merge(link: board_path(@domain, board)) } }
    end
  end

  def update
    respond_to do |format|
      if @board.update(board_params)
        format.json { render json: {}, status: :ok }
      else
        format.json { render partial: 'config_form', status: 400 }
      end
    end
  end

  def sync
    @credentials = Credentials.new(credentials_params)
    if @credentials.valid?
      SyncBoardJob.perform_later(@board.object, @credentials.username, @credentials.password)
      render json: {}, status: 200
    else
      render partial: 'shared/sync_form', status: 400
    end
  end

private
  def credentials_params
    params.require(:credential).permit(:username, :password)
  end

  def board_params
    params.require(:board).permit(:config)
  end
end