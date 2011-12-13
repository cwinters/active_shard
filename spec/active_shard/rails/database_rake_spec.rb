require 'spec_helper'
require 'rake'

describe "rake" do
  subject { Rake::Application.new }

  before do
    Rake.application = subject
    Rake.application.rake_require 'active_shard/rails/database'
    Rake::Task.define_task(:environment)
  end

  describe 'migrate:redo' do
    let(:taskname){'shards:migrate:redo'}
    let(:shard_name){:db1}

    it 'should invoke rollback and then migrate' do
      subject['shards:rollback'].should_receive(:invoke).with(shard_name).ordered
      subject['shards:migrate'].should_receive(:invoke).with(shard_name).ordered
      subject[taskname].invoke(shard_name)
    end

    it 'should invoke down and then up when given a version' do
      ENV["VERSION"] = "0"
      subject['shards:migrate:down'].should_receive(:invoke).with(shard_name).ordered
      subject['shards:migrate:up'].should_receive(:invoke).with(shard_name).ordered
      subject[taskname].invoke(shard_name)
    end
  end
end
