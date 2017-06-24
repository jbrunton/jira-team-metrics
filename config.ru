require 'sinatra'
require 'sinatra/content_for'

['helpers', 'models', 'stores', 'app'].each do |dir|
  Dir.glob("./#{dir}/**.rb").each { |file| require file }
end

map('/domains') { run DomainsController }
map('/') { run HomeController }
