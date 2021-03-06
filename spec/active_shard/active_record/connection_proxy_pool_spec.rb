require 'spec_helper'
require 'active_shard/active_record/connection_proxy_pool'
require 'active_shard/active_record/schema_connection_proxy'
require 'active_shard/shard_definition'
require 'active_record'
require 'active_record/connection_adapters/sqlite3_adapter'

module ActiveShard::ActiveRecord

  describe ConnectionProxyPool, :artifacts => true do
    context "with proxy_class => SchemaConnectionProxy" do
      let :pool do
        shard_definition =
          ActiveShard::ShardDefinition.new( :shard_one,
                                            :schema   => :schema_one,
                                            :adapter  => 'sqlite3',
                                            :database => "#{ARTIFACTS_PATH}/shard_one.db" )

        ConnectionProxyPool.new( shard_definition, :proxy_class => SchemaConnectionProxy )
      end

      describe "#connection" do
        subject { pool.connection }

        it "should return an instance of SchemaConnectionProxy" do
          subject.should be_an_instance_of( SchemaConnectionProxy )
        end
      end

      describe "#disconnect!" do
        it "should run without blowing up" do
          lambda do
            pool.disconnect!
          end.should_not raise_error
        end

      end
    end
  end

end