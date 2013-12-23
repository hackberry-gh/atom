require 'active_support/concern'

module Pubs
  module I18n

    extend ActiveSupport::Concern

    module ClassMethods
      
      def localized_attributes
        @@localized_attributes ||= {}
      end
      
      def localized_attributes=localized_attributes
        @@localized_attributes = localized_attributes
      end     
      
      def localize(store_attribute, *keys)
        keys = keys.flatten
        self.localized_attributes[store_attribute] ||= []
        self.localized_attributes[store_attribute] |= keys
        store_accessor store_attribute, :i18n
      end         

      def store_accessor(store_attribute, *keys)

        keys = keys.flatten

        _store_accessors_module.module_eval do

          keys.each do |key|

            define_method("#{key}=") do |value|
              write_store_attribute(store_attribute, key, value)
            end

            define_method("#{key}") do
              read_store_attribute(store_attribute, key)
            end

          end

          def read_store_attribute(store_attribute, key)
            return super(store_attribute, key) unless self.class.localized_attributes[store_attribute].include?(key)

            attribute = initialize_store_attribute(store_attribute)
            
            # try fetch localised value and fallback to default or atom default
            attribute[:i18n].try(:[],::I18n.locale).try(:[],key) ||
            attribute[:i18n].try(:[],::I18n.default_locale).try(:[],key) ||
            attribute[key]
          end

          def write_store_attribute(store_attribute, key, value)
            return super(store_attribute, key, value) unless self.class.localized_attributes[store_attribute].include?(key)
            
            attribute = initialize_store_attribute(store_attribute)

            # if localised is not set or will change
            if value != attribute[:i18n].try(:[],::I18n.locale).try(:[],key)
              send :"#{store_attribute}_will_change!"
              # set default locale if supplied
              attribute[key] = value if ::I18n.locale == ::I18n.default_locale
              # set localised content
              attribute[:i18n] ||= HashWithIndifferentAccess.new
              attribute[:i18n][::I18n.locale] ||= HashWithIndifferentAccess.new
              attribute[:i18n][::I18n.locale][key] = value
            end
          end

        end

        self.stored_attributes[store_attribute] ||= []
        self.stored_attributes[store_attribute] |= keys
      end
      
    end

  end
  
end