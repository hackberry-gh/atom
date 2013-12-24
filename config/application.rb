require 'i18n'
require 'pubs'

I18n.enforce_available_locales = false
I18n.backend.class.send(:include, I18n::Backend::Fallbacks)
I18n.default_locale = Pubs.cache.get(Pubs.n("default_locale")) || :en
I18n.available_locales = Pubs.cache.get(Pubs.n("available_locales")) || [:en]
Pubs.establish_connection

Time.zone = ENV['TIME_ZONE'] || "London"

require 'app/objects/element'
require 'app/objects/atom'
require 'app/objects/compound'
require 'app/objects/program'
require 'app/objects/context'