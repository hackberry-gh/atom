require "database_cleaner"
require "minitest/pride"
require "minitest/autorun"

DatabaseCleaner.strategy = :deletion

class MiniTest::Spec

  before :each do
    DatabaseCleaner.start
  end

  after :each do
    DatabaseCleaner.clean
    Pubs.cache.flush
  end

  def fixture file, object
    (YAML::load_file("spec/fixtures/#{file}.yml")).symbolize_keys![object]
  end

end