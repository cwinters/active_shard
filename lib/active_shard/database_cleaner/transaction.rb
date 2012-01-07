require 'database_cleaner/active_record/transaction'

module DatabaseCleaner::ActiveShard
  class Transaction
    include ::DatabaseCleaner::ActiveShard::Base

    def start
      for_each_shard do |c|
        c.increment_open_transactions
        c.begin_db_transaction
      end
    end

    def clean
      for_each_shard do |c|
        if c.open_transactions > 0
          c.rollback_db_transaction
          c.decrement_open_transactions
        end
      end
    end
  end
end
