class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_filter :abort_if_syncing

private
  def abort_if_syncing
    byebug
  end
end
