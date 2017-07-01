class BoardsController < ApplicationController
  include ApplicationHelper

  before_action :set_domain
  before_action :set_board

  def show
  end

  def search
    @boards = Board.where('name LIKE ?', "%#{params[:query]}%")
    respond_to do |format|
      format.json { render json: @boards.map{ |board| board.as_json.merge(link: board_path(@domain, board)) } }
      end
  end
end