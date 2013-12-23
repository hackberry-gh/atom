ruby '2.0.0'

source "https://rubygems.org"

gem 'goliath',      '~> 1.0.3'
gem 'pg',           '~> 0.17.0'
gem 'activerecord', '~> 4.0.2'
gem 'dalli',        '~> 2.6.4'
gem 'kgio' # dalli's author says kgio speeds up %15 the memcache, so it's here
gem 'i18n',         '~> 0.6.9'
gem 'ip_country'

group :test do
  gem "minitest"
  gem "database_cleaner"
  gem 'em-http-request'
  gem 'em-websocket-client'
  gem 'timecop'
  gem 'awesome_print'
end