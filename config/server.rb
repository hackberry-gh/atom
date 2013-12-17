# require 'active_support/hash_with_indifferent_access'
# config["roles"] = Pubs.config(:roles)
# config["models"] = ActiveSupport::HashWithIndifferentAccess.new
# I18n.available_locales.each { |locale|
#   I18n.with_locale(locale) {
#     Model.all.each { |model|
#       config["models"][model.collection_name] ||= {}
#       config["models"][model.collection_name][locale] = [ model.generate_class, model ]
#     }
#   }
# }
# config["models"]["models"] = {I18n.default_locale.to_s => [Model] }
# config["models"]["jobs"] = {I18n.default_locale.to_s => [Jobs] }
# config["models"]["tasks"] = {I18n.default_locale.to_s => [Task] }
# 
# config["allowed_origins"] = ( Pubs.cache.get("#{ENV['APP_NAME']}:allowed_origins") || "").split(",")