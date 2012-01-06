require 'active_record/fixtures'
module ActiveShard
  class Fixtures
    class << self
      def create_fixtures(fixtures_dir, *args)
        schemas = ActiveShard.schemas.map(&:to_sym) & Dir.entries(fixtures_dir).map(&:to_sym)

        self.by_schema.merge!(
          schemas.inject({}) do |hash, schema|
            hash[schema] = Schema.new(schema, File.join(fixtures_dir, schema.to_s), *args)
            hash
          end
        )
      end

      def by_schema
        @by_schema ||= {}
      end

      def [](key)
        by_schema[key]
      end
    end

    class Schema
      def initialize(schema, schema_fixtures_dir, *args)
        shards = ActiveShard.shards_by_schema(schema).map{|s| s.name.to_sym} & Dir.entries(schema_fixtures_dir).map(&:to_sym)

        self.by_shard.merge!(
          shards.inject({}) do |hash, shard|
            hash[shard] = Shard.new(schema, shard, File.join(schema_fixtures_dir, shard.to_s), *args)
            hash
          end
        )
      end

      def by_shard
        @by_shard ||= {}
      end

      def [](key)
        by_shard[key]
      end
    end

    class Shard
      def initialize(schema, shard, shard_fixtures_dir, *args)
        @connection = ::ActiveRecord::Base.connection_handler.connection_pool(schema,shard).connection
        @fixtures_dir = shard_fixtures_dir
        @fixture_names = Dir[File.join(@fixtures_dir, '*.yml')].map {|f| File.basename(f, '.yml') }

        @fixtures = ::Fixtures.create_fixtures(@fixtures_dir, @fixture_names, *args) do
          @connection
        end
      end
    end
  end
end
