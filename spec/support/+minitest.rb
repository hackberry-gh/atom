require "database_cleaner"
require "minitest/pride"
require "minitest/autorun"
require 'awesome_print'

DatabaseCleaner.strategy = :deletion

class MiniTest::Spec

  before :each do
    I18n.locale = I18n.default_locale
    DatabaseCleaner.start
    Program.redefine        
    Context.redefine
    Sequence.redefine        
    Event.redefine        
  end

  after :each do
    DatabaseCleaner.clean
    Pubs.cache.flush
  end

  def fixture file, object
    (YAML::load_file("spec/fixtures/#{file}.yml")).symbolize_keys![object]
  end

end