class DomainsController < ApplicationController
  before_action :set_domain, only: [:show, :sync, :update, :destroy]
  include ApplicationHelper

  def show
    @boards = @domain.boards.select do |board|
      !board.last_synced.nil?
    end
  end

  def update
    if ENV['READONLY']
      render json: {}, status: 401
    elsif @domain.update(domain_params)
      render json: {}, status: :ok
    else
      render partial: 'config_form', status: 400
    end
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
    params.require(:domain).permit(:name, :url, :config_string)
  end

  def credentials_params
    params.require(:credential).permit(:username, :password)
  end
end
