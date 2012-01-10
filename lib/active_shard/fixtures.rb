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

      def reset!
        schemas.each(&:reset!)

        @by_schema = {}
      end

      def by_schema
        @by_schema ||= {}
      end

      def schemas
        by_schema.values
      end

      def [](key)
        by_schema[key]
      end

      def setup_fixture_accessors obj
        schemas.each do |schema|
          schema.setup_fixture_accessors obj
        end
      end
    end

    class Schema
      attr_reader :schema

      def initialize(schema, schema_fixtures_dir, *args)
        @schema = schema

        shards = ActiveShard.shards_by_schema(schema).map{|s| s.name.to_sym} & Dir.entries(schema_fixtures_dir).map(&:to_sym)

        self.by_shard.merge!(
          shards.inject({}) do |hash, shard|
            hash[shard] = Shard.new(schema, shard, File.join(schema_fixtures_dir, shard.to_s), *args)
            hash
          end
        )
      end

      def reset!
        shards.each(&:reset!)
      end

      def by_shard
        @by_shard ||= {}
      end

      def shards
        by_shard.values
      end

      def [](key)
        by_shard[key]
      end

      def setup_fixture_accessors obj
        shards.each do |shard|
          shard.setup_fixture_accessors obj
        end
      end
    end

    class Shard
      attr_reader :schema
      attr_reader :shard
      attr_reader :fixture_names
      attr_reader :fixtures

      def initialize(schema, shard, shard_fixtures_dir, *args)
        @schema = schema
        @shard = shard

        @fixtures_dir = shard_fixtures_dir
        @fixture_names = Dir[File.join(@fixtures_dir, '*.yml')].map {|f| File.basename(f, '.yml') }

        @fixtures = ::Fixtures.create_fixtures(@fixtures_dir, @fixture_names, *args) do
          connection
        end
      end

      def connection
        @connection ||= ::ActiveRecord::Base.connection_handler.connection_pool(@schema,@shard).connection
      end

      def setup_fixture_accessors obj
        fixture_names = self.fixture_names
        loaded_fixtures = ::Fixtures.cache_for_connection(connection)

        fixture_names.each do |table_name|
          table_name = table_name.to_s.tr('./', '_')

          obj.class.send(:define_method, table_name) do |*fixtures|
            force_reload = fixtures.pop if fixtures.last == true || fixtures.last == :reload

            @fixture_cache ||= {}
            @fixture_cache[table_name] ||= {}

            instances = fixtures.map do |fixture|
              @fixture_cache[table_name].delete(fixture) if force_reload
              if loaded_fixtures[table_name][fixture.to_s]
                @fixture_cache[table_name][fixture] ||= loaded_fixtures[table_name][fixture.to_s].find
              else
                raise StandardError, "No fixture with name '#{fixture}' found for table '#{table_name}'"
              end
            end

            instances.size == 1 ? instances.first : instances
          end
        end
      end

      def reset!
        ::Fixtures.reset_cache connection
      end
    end
  end
end
