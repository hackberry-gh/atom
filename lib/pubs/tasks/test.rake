desc "run tests, to run single file rake test[filename_without _spec.rb]"
task :test,[:file] do |t,args|

  ENV['RACK_ENV'] = "test"

  require 'config/application'

  # include support files
  Dir.glob('spec/support/*.rb') { |f| require f }

  # Run them all or only one
  if args[:file].nil?
    Dir.glob('spec/**/*_spec.rb') { |f| require f }
  else
    require "spec/#{args[:file]}_spec.rb"
  end

end

task default: :test