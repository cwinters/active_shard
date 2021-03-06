require 'active_support/core_ext/module/delegation'
require 'active_shard/exceptions'

module ActiveShard
  module ActiveRecord

    # SchemaConnectionProxy holds a Connection object and restricts messages passed
    # to it. Only schema-ish messages are allowed.
    #
    class SchemaConnectionProxy

      delegate :columns,
               :verify,
               :verify!,
               :run_callbacks,
               :_run_checkin_callbacks,
               :quote_table_name,
               :quote_value,
               :disconnect!,
               :sanitize_limit,
               :quote, :to => :target

      def initialize( target )
        @target = target
      end

      def cache
        yield
      end

      def method_missing( sym, *args, &block )
        raise ::ActiveShard::NoActiveShardError
      end

      private
        def target
          @target
        end
    end
  end
end