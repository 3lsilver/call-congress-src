require 'rubygems'
require 'dm-core'
require 'digest/sha1'

class User
  include DataMapper::Resource
  
  property :id, Serial
  property :username, String
  property :email, String
  property :hashed_password, String
  property :salt, String
  property :fullname, String
  property :created_at, Time, :default => Time.now
    
  validates_present :username, :email, :hashed_password, :salt
  
  has n, :call_comments, :class_name => "CallComment"
  has n, :calls, :class_name => "Call"
  has n, :phones, :class_name => "Phone"
  
  # Password methods
  #http://www.aidanf.net/rails_user_authentication_tutorial
  def self.random_string(len)
    #generate a random password consisting of strings and digits
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end
  def password=(pass)
    @password=pass
    self.salt = User.random_string(10) if !self.salt
    self.hashed_password = User.encrypt(@password, self.salt)
  end
  def self.encrypt(pass, salt)
     Digest::SHA1.hexdigest(pass+salt)
  end
  def self.authenticate(username, pass)
    u=self.first(:username.eql => username)
    return nil if u.nil?
    return u if User.encrypt(pass, u.salt)==u.hashed_password
    nil
  end 
  
  def phones
    Phone.all(:user_id.eql => self.id, :order => [:primary.desc])
  end
  def primary_phone
    Phone.first(:user_id.eql => self.id, :primary => true)
  end
  
  def add_phone(num)
    if num.class == String
      num = Phone.string_to_number(num)
    end
    @phone = Phone.create(:number => num, :user_id => self.id)
    if @phone.make_primary?
      @phone.primary = true
      @phone.save
    end      
    return true if @phone.save
    return false
  end
  
  def remove_phone(phone_id)
    @phone = self.phones.select {|p| p.id == phone_id.to_i}[0]
    if @phone
      return true if @phone.destroy
      return false
    else
      return false
    end
  end
end