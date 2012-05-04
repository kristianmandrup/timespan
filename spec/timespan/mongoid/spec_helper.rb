require 'spec_helper'
require 'mongoid'
require 'bson'

Mongoid.configure.master = Mongo::Connection.new.db('timespan')

Mongoid.database.collections.each do |coll|
  coll.remove
end

require 'timespan/mongoid'
require 'timespan/mongoid/account'