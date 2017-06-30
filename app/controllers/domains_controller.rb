class DomainsController < ApplicationController
  before_action :set_domain, only: [:show, :sync, :destroy]
  include FormattingHelpers
  include ApplicationHelper

  def index
    @domains = Domain.all
    @domain = Domain.new
  end

  def show
    @boards = @domain.boards.select do |board|
      !board.last_synced.nil?
    end
  end

  def create
    @domain = Domain.new(domain_params)
    if @domain.save
      render json: { target: domain_path(@domain) }, status: 200
    else
      render partial: 'form', status: 400
    end
  end

  def destroy
    @domain.destroy
    render json: { target: domains_path }, status: 200
  end

  def sync
    SyncDomainJob.perform_later(@domain)
  end

private
  def domain_params
    params.require(:domain).permit(:name, :url)
  end
end
