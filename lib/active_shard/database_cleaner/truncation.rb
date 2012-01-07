require 'database_cleaner/active_record/truncation'

module DatabaseCleaner::ActiveShard
  class Truncation
    include ::DatabaseCleaner::ActiveShard::Base
    include ::DatabaseCleaner::Generic::Truncation

    def clean
      for_each_shard do |c|
        c.disable_referential_integrity do
          c.truncate_tables(tables_to_truncate(c))
        end
      end
    end

    private
    def tables_to_truncate(connection)
      (@only || connection.tables) - @tables_to_exclude - connection.views
    end

    # overwritten
    def migration_storage_name
      'schema_migrations'
    end
  end
end
