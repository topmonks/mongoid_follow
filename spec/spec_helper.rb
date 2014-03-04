require "rubygems"

require "database_cleaner"
require "mongoid"
require "rspec"

Mongoid.configure do |config|
  config.connect_to("mongoid_follow_test")
end

require File.expand_path("../../lib/mongoid_follow", __FILE__)
require File.expand_path("../models/user", __FILE__)
require File.expand_path("../models/other_user", __FILE__)
require File.expand_path("../models/group", __FILE__)

RSpec.configure do |c|
  c.before(:all) { DatabaseCleaner.strategy = :truncation }
  c.before(:each) { DatabaseCleaner.clean }
end
