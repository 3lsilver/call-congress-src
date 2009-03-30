require 'rubygems'
require 'dm-core'

class CallStatus
  include DataMapper::Resource
  
  property :id, Serial
  property :label, String
  property :short_desc, String
  property :description, Text
  
  @@statuses = {
    "dial" => ["Dialing", "<p>Your phone should ring any second. The caller id will read \"Unknown\", \"Private,\" \"000-000-0000\" or something similar.</p>"],
    "answer" => ["Answered", "<p>You have answered the call. Press 1 to connect the call to the legislator's office. Or press 2 to hangup and cancel the call</p>"],
    "callout" => ["Dialing Legislator", "<p>We are now trying to reach the legislator's office. You will hear ringing before they pick up.</p>"],
    "connected" => ["Connected", "<p>You are now connected with the legislator.</p>"],
    "hungup" => ["Call Ended", ""]
  }
  
  def self.populate
    CallStatus.all.map{|cs| cs.destroy}
    @@statuses.each do |k, v|
      CallStatus.create(:label => k, :short_desc => v[0], :description => v[1])
    end
  end
  
end