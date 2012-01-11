require 'spec_helper'
require 'active_shard'
require 'active_shard/fixtures'

require 'sqlite3'
require 'active_record'
require 'active_record/connection_adapters/sqlite3_adapter'
require "active_shard/active_record"


describe ActiveShard::Fixtures do
  before :all do
    ActiveRecord::Base.send( :include, ActiveShard::ActiveRecord::ShardSupport )

    handler =
      ActiveShard::ActiveRecord::ConnectionHandler.new(
        :shard_lookup => ActiveShard::ShardLookupHandler.new( :scope => ActiveShard.scope )
    )

    ActiveShard.add_shard_observer handler

    ActiveRecord::Base.connection_handler = handler

    ActiveShard.add_shard( :db1, :schema => 'data', adapter: 'sqlite3', database: ':memory:' )
    ActiveShard.add_shard( :db2, :schema => 'data', adapter: 'sqlite3', database: ':memory:' )
  end

  let(:db1){ActiveRecord::Base.connection_handler.connection_pool(:data, :db1).connection}
  let(:db2){ActiveRecord::Base.connection_handler.connection_pool(:data, :db2).connection}

  around :each do |ex|
    [db1,db2].each do |db|
      db.create_table :test_table do |t|
        t.string :col1
      end
    end

    ex.run

    [db1,db2].each do |db|
      db.drop_table :test_table
    end
  end

  #after :all do
  #  ActiveShard.config.reset!
  #end

  it "should load fixtures from a directory tree" do
    ActiveShard::Fixtures.create_fixtures("spec/fixtures/fixtures")

    query = 'select * from test_table'

    res = db1.execute(query)

    res.length.should == 1
    res[0]['col1'].should == 'some data'

    db2.execute(query).length.should == 0
  end
end
