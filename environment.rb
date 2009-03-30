require 'rubygems'
require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-aggregates'
require 'haml'
require 'open-uri'
require 'json'
require 'ostruct'
require 'drb'
require 'lib/vendor/spork'

require 'sinatra' unless defined?(Sinatra)

configure do
  SiteConfig = OpenStruct.new(YAML.load_file("settings.yaml"))
  enable :sessions
end
configure :development do
# DB connection
  DataMapper.setup(:default, "sqlite3://#{File.dirname(File.expand_path(__FILE__))}/db/development.db")

end

configure :production do
# DB connection
  DataMapper.setup(:default, "sqlite3://#{File.dirname(File.expand_path(__FILE__))}/db/production.db")

end
