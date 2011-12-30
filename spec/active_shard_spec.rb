require 'spec_helper'

describe ActiveShard do
  it 'should pass the environment on to config when calling shards_by_schema' do
    ActiveShard.config.should_receive(:shards_by_schema).with(:environment, :schema)
    ActiveShard.environment = :environment
    ActiveShard.shards_by_schema(:schema)
  end

  describe '#schemas' do
    it 'should get schemas from config' do
      ActiveShard.config.should_receive(:schemas).with(:environment)
      ActiveShard.environment = :environment
      ActiveShard.schemas
    end
  end
end
