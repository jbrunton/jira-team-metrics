class DomainsController < ApplicationController
  before_action :set_domain, only: [:show]

  def index
    @domains = DomainsStore.instance.all
  end

  def show
    @boards = Store::Boards.instance(@domain['name']).all.select do |board|
      !board.last_updated.nil?
    end
  end
end
