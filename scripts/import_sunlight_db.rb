# RUN FROM APP ROOT DIRECTORY, NOT SCRIPTS DIR

ROOT = File.dirname(__FILE__)
require "#{ROOT}/../application"

# Download API CSV Here: 
# http://services.sunlightlabs.com/api/media/apidump.csv.gz
# gunzip it and put it in the same directory as this script
# Filename should be apidump.csv

if !File.exists?(ROOT+"/apidump.csv")
  puts "ERROR: You must download the Sunlight API Dump first"
  puts "(See script for details)"
  Process.exit!
else
  lines = File.open("#{ROOT}/apidump.csv", "r").read.split("\r\n")
  specs = lines.shift.split(",").map{|s| s.intern}
  puts "Deleting old database"
  Legislator.all.map{|l| l.destroy}
  if Legislator.all.size == 0
    puts "Successfully deleted old database"
  else
    puts "Error deleting database - run the script again"
    Process.exit!
  end
  puts "Populating database with new data"
  puts "---------------------------------"
  lines.each do |line|
    replacing = true
    while replacing == true
      replacing = line.gsub!(/("[^"]*),([^"]*")/, '\1COMMA\2')
    end
    vals = line.split(",").map{|v| v.gsub(/COMMA/, ",")}
    params = specs.zip(vals).to_hash
    leg = Legislator.create(params)
    if leg.save
      puts "created #{leg.firstname} #{leg.lastname}"
    else
      puts "error saving #{vals[1]} #{vals[3]}"
      puts leg.errors.inspect
      puts params.inspect
      puts line
      puts vals
    end
  end
  if Legislator.all.size == lines.size
    puts "Successfully updated database"
  else
    puts "Error updating database - only #{Legislator.all.size} records created out of #{lines.size} total"
  end
  puts "---------------------------------"
end
