require 'spec_helper'
require 'mongoid'

# puts "version: #{Mongoid::VERSION}"

require 'timespan/mongoid/mongoid_setup'

Mongoid.configure do |config|
  Mongoid::VersionSetup.configure config
end

if RUBY_VERSION >= '1.9.2'
  YAML::ENGINE.yamler = 'syck'
end

RSpec.configure do |config|
  # config.mock_with(:mocha)

  config.before(:each) do
    Mongoid.purge!
    # Mongoid.database.collections.each do |collection|
    #   unless collection.name =~ /^system\./
    #     collection.remove
    #   end
    # end
  end
end

require 'timespan/mongoid'

def load_models!
  require "timespan/mongoid/models/account_#{Mongoid::MAJOR_VERSION}x"
end