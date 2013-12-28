require 'i18n'
require 'pubs'

I18n.enforce_available_locales = false
I18n.backend.class.send(:include, I18n::Backend::Fallbacks)
I18n.default_locale = Pubs.cache.get(Pubs.n("default_locale")) || :en
I18n.available_locales = Pubs.cache.get(Pubs.n("available_locales")) || [:en]
Pubs.establish_connection

Time.zone = ENV['TIME_ZONE'] || "London"

require 'objects/element'
require 'objects/atom'
require 'objects/compound'
require 'objects/program'
require 'objects/context'
require 'objects/event'
require 'objects/sequence'