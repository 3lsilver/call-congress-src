require 'application'
require 'spec/rake/spectask'

task :default => :test
task :test => :spec

if !defined?(Spec)
  puts "spec targets require RSpec"
else
  desc "Run all examples"
  Spec::Rake::SpecTask.new('spec') do |t|
    t.spec_files = FileList['spec/**/*.rb']
    t.spec_opts = ['-cfs']
  end
end

namespace :db do

  desc 'Auto-upgrade the database (preserves data)'
  task :upgrade do
    DataMapper.setup(:default, "sqlite3://#{File.dirname(File.expand_path(__FILE__))}/db/production.db")    
    DataMapper.auto_upgrade!
  end
end

namespace :update do
  desc "Download bioguide pics for all legislators in DB"
  task :pics do
    `ruby scripts/download_pics.rb`
  end
end


namespace :gems do
  desc 'Install required gems'
  task :install do
    required_gems = %w{ sinatra rspec dm-core dm-validations
                        dm-aggregates haml json }
    required_gems.each { |required_gem| system "sudo gem install #{required_gem}" }
  end
end
