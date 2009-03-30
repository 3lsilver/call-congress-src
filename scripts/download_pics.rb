# RUN FROM APP ROOT DIRECTORY, NOT SCRIPTS DIR

ROOT = File.dirname(__FILE__)
require "#{ROOT}/../application"
require 'open-uri'

PICS_DIR = "#{ROOT}/../public/images/bioguide/"

def make_pic(leg)
  begin
    pic = open("http://bioguide.congress.gov/bioguide/photo/#{leg.bioguide_id[0].chr }/#{leg.bioguide_id}.jpg").read
    puts "Downloaded pic for: #{leg.fullname}"
  rescue
    pic = File.open(PICS_DIR+"no_photo.jpg", "r").read
    puts "ERROR: No pic for #{leg.fullname}"
  ensure
    File.open(PICS_DIR+"#{leg.bioguide_id}.jpg", "w") {|f| f.write(pic)}
    puts "Wrote pic file for #{leg.fullname}"
  end  
end
  
puts "Beginning downloads"
Legislator.all.each do |leg|
  puts "Downloading for #{leg.fullname}"
  make_pic(leg)
end
puts "All finished"