require 'rubygems'
require 'dm-core'

class Tag
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String
  
  has n, :call_tags
  has n, :calls, :through => :call_tags, :class_name => "Call", :child_key => []
end
