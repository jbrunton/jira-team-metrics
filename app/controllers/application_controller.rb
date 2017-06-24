class ApplicationController < Sinatra::Base
  helpers Sinatra::ContentFor
  helpers ApplicationHelper

  # set folder for templates to ../views, but make the path absolute
  set :views, File.expand_path('../../views', __FILE__)
end
