require 'application'

set :run, false
set :env, (ENV['RACK_ENV'] ? ENV['RACK_ENV'].to_sym : :development)

FileUtils.mkdir_p 'log' unless File.exists?('log')
log = File.new("log/sinatra.log", "a")
STDOUT.reopen(log)
STDERR.reopen(log)

run Sinatra::Application
