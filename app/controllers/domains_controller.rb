class DomainsController < ApplicationController
  helpers DomainsHelper

  before ('/:domain*') { set_domain(params) }
  before ('/:domain/boards/:board_id*') { set_board(params) }

  get '/' do
    @domains = DomainsStore.instance.all
    erb 'domains/index'.to_sym
  end

  get '/:domain' do
    @boards = Store::Boards.instance(@domain['name']).all.select do |board|
      !board.last_updated.nil?
    end
    erb 'domains/show'.to_sym
  end
end
