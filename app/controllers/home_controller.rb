class HomeController < ApplicationController
  get '/' do
    redirect to(domains_path)
  end
end
