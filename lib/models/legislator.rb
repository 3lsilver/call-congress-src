require 'rubygems'
require 'dm-core'

class Legislator
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  property :firstname, String
  property :middlename, String
  property :lastname, String
  property :name_suffix, String
  property :nickname, String
  property :party, String
  property :state, String
  property :district, Integer
  property :in_office, Boolean
  property :gender, String
  property :phone, String
  property :fax, String
  property :website, Text
  property :webform, Text
  property :email, String
  property :congress_office, Text
  property :bioguide_id, String, :key => true
  property :votesmart_id, String
  property :fec_id, String
  property :govtrack_id, String
  property :crp_id, String
  property :eventful_id, String
  property :sunlight_old_id, String
  property :twitter_id, String, :null => true
  property :congresspedia_url, Text
  property :youtube_url, Text
  property :official_rss, Text
  
  has n, :calls, :class_name => "Call"
  
  validates_present :in_office, :state, :party, :lastname, :firstname, :bioguide_id
  
  
  def fullname
    self.firstname+" "+self.lastname
  end
  
  def calls
    Call.all(:legislator_bioguide_id.eql => self.bioguide_id)
  end
  
  def tags
    tags = Set.new
    calls.map{|c| c.tags.map{|t| tags << t}}
    tags.to_a
  end
  
  def senator?
    self.title == "Sen" && self.district == nil
  end
  
  def quals
    if self.senator?
      "#{self.party}-#{self.state}"
    else
      "#{self.party}/#{self.state}-" + sprintf("%02d", self.district)
    end
  end
  
  def number
    Phone.string_to_number(@phone)
  end
  
  def numberf
    Phone.number_to_string(self.number)
  end
  
end

# Sample line from Sunlight CSV Data Dump
#  Rep,Neil,,Abercrombie,,,D,HI,1,1,M,202-225-2726,202-225-4580,http://www.house.gov/abercrombie/,http://www.house.gov/writerep/,Neil.Abercrombie@mail.house.gov,1502 Longworth House Office Building,A000014,26827,H6HI01121,400001,N00007665,P0-001-000016130-0,fakeopenID1,neilabercrombie,http://www.sourcewatch.org/index.php?title=Neil_Abercrombie,