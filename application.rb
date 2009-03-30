require 'rubygems'
require 'sinatra'
require 'environment'

configure do
  set :views, "#{File.dirname(__FILE__)}/views"
end

not_found do
  haml :'404'
end

error do
  e = request.env['sinatra.error']
  puts e.to_s
  puts e.backtrace.join('\n')
  haml :'500'
end

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")

# load controllers
Dir.glob("#{File.dirname(__FILE__)}/lib/controllers/*.rb") { |lib| 
  load "controllers/"+File.basename(lib) 
}
  
# load models
Dir.glob("#{File.dirname(__FILE__)}/lib/models/*.rb") { |lib| 
  require "models/"+File.basename(lib, ".*") 
}



# load helpers
require 'lib/helpers'

