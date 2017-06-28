class DomainsController < ApplicationController
  before_action :set_domain, only: [:show, :sync]
  helper FormattingHelpers

  def index
    @domains = Domain.all
  end

  def show
    @boards = @domain.boards.select do |board|
      !board.last_synced.nil?
    end
  end

  def create
    byebug
    Domain.create(domain_params)
    redirect_to domains_path
  end

  def sync
    SyncDomainJob.perform_later(@domain)
  end

private
  def domain_params
    params.permit(:name, :url)
  end
end
