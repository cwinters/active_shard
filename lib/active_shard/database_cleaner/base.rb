require 'database_cleaner/active_record/base'

module DatabaseCleaner
  module ActiveShard
    def self.acailable_strategies
      %w[truncation transaction]
    end

    module Base
      include ::DatabaseCleaner::Generic::Base

      private
      def connection(schema, shard)
        ::ActiveRecord::Base.connection_handler.connection_pool(schema, shard).connection
      end

      def for_each_shard
        ::ActiveShard.schemas.each do |schema|
          ::ActiveShard.shards_by_schema(schema).each do |shard|
            yield connection(schema, shard.name)
          end
        end
      end
    end
  end
end
