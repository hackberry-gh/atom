# real time stdout
$stdout.sync = true

%w(. lib app).each do |dir|
  path = File.expand_path( "../../#{dir}", __FILE__)
  $LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
end

require 'bundler/setup'
Bundler.setup