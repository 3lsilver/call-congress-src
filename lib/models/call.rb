require 'rubygems'
require 'dm-core'

class Call
  
  include DataMapper::Resource
  property :id, Serial
  property :user_id, Integer, :null => true
  property :legislator_bioguide_id, String
  property :phone_id, Integer
  property :asterisk_unique_id_1, String, :null => true
  property :unique_id, String, :default => lambda { Call.generate_id }
  property :call_status_label, String, :null => true
  property :completed, Boolean, :default => false
  property :cancelled, Boolean, :default => true  
  property :created_at, Time, :default => Time.now
  property :commentary, Text
  
  @@unique_ids = Call.all.map {|c| c.unique_id}
#  @@config = YAML.load("../../settings.yaml")
  @@ahn = DRbObject.new_with_uri("druby://localhost:8888")
  
  has n, :call_comments, :class_name => "CallComment"
  has n, :call_tags
  has n, :tags, :through => :call_tags, :class_name => "Tag", :child_key => []
  has 1, :phone, :class_name => "Phone"
  has 1, :legislator, :class_name => "Legislator", :child_key => [:legislator_bioguide_id]
  has 1, :call_status, :class_name => "CallStatus"
  belongs_to :user, :class_name => "User"
  
  def status
    CallStatus.first(:label.eql => self.call_status_label)    
  end
  def status=(label)
    self.call_status_label = label
  end
  
  def legislator
    Legislator.first(:bioguide_id.eql => self.legislator_bioguide_id)
  end
  
  def phone
    Phone.get(@phone_id)
  end
    
  def comments
    self.call_comments
  end

  def tags
    CallTag.all(:call_id => self.unique_id).map{|ct| Tag.get(ct.tag_id)}.flatten
  end
  
  # Disable ability to set unique_id
  def unique_id=(arg)
    return false
  end
  
  # Get @@unique_ids
  def unique_ids
    @@unique_ids
  end
  
  after :create, :update_unique_ids_array
  
  def update_unique_ids_array
    @@unique_ids << self.unique_id
  end
  
  def self.generate_id(id=nil)
    # Function only takes an argument for testing purposes
    # If it receives an argument, does not generate an id
    unless id
      chars = ("a".."z").to_a + ("0".."9").to_a
      str = ""
      8.times do
        str << chars[rand(chars.size)]
      end
    else
      str = id
    end
    if @@unique_ids.include?(str)
      self.generate_id
    else
      str
    end
  end

  def place
    place_to(self.legislator.number)
  end

  def place_to(num)
    #Make sure this works with your extensions.conf
    self.status = "dial"
    self.save
    call_options = {
      "Channel" => "SIP/+1#{self.phone.number}@voicepulse-primary",
      "Exten" => 999,
      "Context" => "callcongress",
      "Priority" => 1,
      "Async" => false,
      "ActionID" => self.unique_id,
      "Timeout" => 30000,
      "Variable" => "num1=#{self.phone.number}|num2=#{num}|callid=#{self.unique_id}|audiodir=#{SiteConfig.audio_dir}"
    }
      @@ahn.originate(call_options)
  end  
  
end