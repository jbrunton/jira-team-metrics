require 'sinatra'
require 'sinatra/content_for'
require 'yaml/store'
require 'require_all'

['helpers', 'models', 'stores', 'app'].each { |dir| require_all dir }

map('/domains') { run DomainsController }
map('/reports') { run ReportsController }
map('/api') { run ApiController }
map('/components') { run ComponentsController }
map('/') { run HomeController }
