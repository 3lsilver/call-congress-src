require 'rubygems'
require 'dm-core'

class CallTag
  include DataMapper::Resource
  
  property :id, Serial
  property :call_id, String
  property :tag_id, Integer
  
  belongs_to :tag, :class_name => "Tag"
  belongs_to :call, :class_name => "Call"
end