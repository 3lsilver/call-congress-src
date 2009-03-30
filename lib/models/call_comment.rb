require 'rubygems'
require 'dm-core'

class CallComment
  include DataMapper::Resource
  property :id, Serial
  property :user_id, Integer, :key => true
  property :call_id, Integer, :key => true
  property :created_at, Time, :default => Time.now
  property :comment, Text, :null => false
  
  belongs_to :call, :class_name => "Call"
  belongs_to :user, :class_name => "User"
  
  validates_present :comment
end