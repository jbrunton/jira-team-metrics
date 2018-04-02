class BoardsController < ApplicationController
  include ApplicationHelper

  before_action :set_domain
  before_action :set_board, only: [:show, :update, :sync]

  def show
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
      SyncBoardJob.perform_later(@board.object, @credentials.username, @credentials.password, days_to_sync)
      render json: {}, status: 200
    else
      render partial: 'shared/sync_form', status: 400
    end
  end

private
  def credentials_params
    params.require(:credential).permit(:username, :password)
  end

  def days_to_sync
    params.require(:days_to_sync).to_i
  end

  def board_params
    params.require(:board).permit(:config_string)
  end
end