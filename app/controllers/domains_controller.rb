class DomainsController < ApplicationController
  before_action :set_domain, only: [:show]
  helper FormattingHelpers

  def index
    @domains = Domain.all
  end

  def show
    @boards = @domain.boards.select do |board|
      !board.last_synced.nil?
    end
  end
end
