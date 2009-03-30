require 'rubygems'
require 'dm-core'

class Phone
  include DataMapper::Resource
  property :id, Serial
  property :number, Integer, :null => false, :format => lambda {|n| n.to_s.length == 10 }
  property :label, String
  property :user_id, Integer, :null => true
  property :verified, Boolean, :default => false
  property :primary, Boolean, :default => false
  property :created_at, Time, :default => Time.now
  
  has n, :calls, :class_name => "Call"
  
  validates_is_number :number
    
  def user
    User.first(:id.eql => self.user_id) || nil
  end
  
  def user=(uid)
    self.user_id = uid
    self.save
  end
  
  def make_primary?
    return true if self.user.phones.size == 1
  end
  
  def make_primary
    self.user.phones.each {|p| p.primary = false; p.save}
    self.primary = true
    self.save
  end
  
  
  def self.string_to_number(phone_str)
    num = phone_str.gsub(/[^\d]/, "")
    if num.length == 10
      return num.to_i
    else
      return false
    end
  end
  
  def self.number_to_string(phone_num)
    num = phone_num.to_s
    num[0..2]+"-"+num[3..5]+"-"+num[6..9]
  end

  def numberf
    Phone.number_to_string(self.number)
  end

  
end