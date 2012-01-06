require 'spec_helper'

describe ActiveShard::TestFixtures do
  subject {Class.new.include(ActiveShard::TestFixtures)}
  it "should load fixtures from a directory tree"
    # schemas/shards/fixtures
    #ActiveShard::TestFixtures File.expand_path("../../fixtures_directory", __FILE__)
end
