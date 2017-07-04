class DomainsController < ApplicationController
  before_action :set_domain, only: [:show, :sync, :update, :destroy]
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

  def update
    respond_to do |format|
      if @domain.update(domain_params)
        format.json { render json: {}, status: :ok }
      else
        format.json { render partial: 'config_form', status: 400 }
      end
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
    params.require(:domain).permit(:name, :url, :config)
  end

  def credentials_params
    params.require(:credential).permit(:username, :password)
  end
end
