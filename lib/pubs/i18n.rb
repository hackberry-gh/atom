require 'active_support/concern'

module Pubs
  module I18n

    extend ActiveSupport::Concern

    module ClassMethods
      
      def overrides
        @@overrides ||= []
      end
      
      def localized_attributes
        @@localized_attributes ||= [:attributes, :validations, :callbacks, :translations]
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
            return super(store_attribute, key) unless self.class.localized_attributes.include?(key)
            attribute = initialize_store_attribute(store_attribute)
            # try fetch localised value and fallback to default or atom default
            attribute[:i18n].try(:[],::I18n.locale).try(:[],key) ||
            attribute[:i18n].try(:[],::I18n.default_locale).try(:[],key) ||
            attribute[key]
          end

          def write_store_attribute(store_attribute, key, value)
            return super(store_attribute, key, value) unless self.class.localized_attributes.include?(key)
            attribute = initialize_store_attribute(store_attribute)

            # if localised is not set or will change
            if value != attribute[:i18n].try(:[],::I18n.locale).try(:[],key)
              send :"#{store_attribute}_will_change!"
              # set default locale if supplied
              attribute[key] = value if ::I18n.locale == ::I18n.default_locale
              # set localised content
              attribute[:i18n] ||= {}
              attribute[:i18n][::I18n.locale] ||= {}
              attribute[:i18n][::I18n.locale][key] = value
            end
          end

        end

        self.stored_attributes[store_attribute] ||= []
        self.stored_attributes[store_attribute] |= keys
      end
      
      def method_added(name)
        if [:class_name,:gen!].include?(name) && !self.overrides.include?(name)
          self.overrides << name
          alias_method :"default_#{name}", name
          alias_method name, :"localised_#{name}"          
        end
      end
      
    end
    
    included do
      if self.name == "Element"
        store_accessor :meta, :name, :group, :primary_key,
        :attributes, :validations, :callbacks, :translations, :localize, :i18n
      end
    end
    
    def compound_code
      <<-CODE
        class #{self.name} < Compound
        end
      CODE
    end
    
    
    def localised_class_name
      self.localize.nil? ? default_class_name : "#{self.name}#{::I18n.locale.to_s.classify}"
    end
    
    
    def localised_gen!
      if self.localize.nil?
        default_gen!
      else
        Object.module_eval compound_code
        ([::I18n.default_locale] + self.i18n.keys).each do |locale|
          ::I18n.with_locale(locale.to_sym) do
            default_gen!
          end
        end
        self.name.constantize.register_locales
      end
    end

  end
  
end