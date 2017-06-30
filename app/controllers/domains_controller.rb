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
    @credentials = Credentials.new
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
    @credentials = Credentials.new(credentials_params)
    if @credentials.valid?
      SyncDomainJob.perform_later(@domain, @credentials.username, @credentials.password)
      render json: {}, status: 200
    else
      render partial: 'shared/sync_form', status: 400
    end
  end

private
  def domain_params
    params.require(:domain).permit(:name, :url)
  end

  def credentials_params
    params.require(:credentials).permit(:username, :password)
  end
end
