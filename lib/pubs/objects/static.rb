require 'active_support/concern'
require 'pubs/i18n'

module Pubs
  module Objects
    module Static
      
      extend ActiveSupport::Concern
      include Pubs::I18n
      
      module ClassMethods
        
        def define data
          data = class_variable_set(:"@@#{self.name.underscore}_element_data",data)
          element = Element.find_by(name: data["name"]) || Element.create!(YAML::load(data))
          class_variable_set(:"@@#{self.name.underscore}_element_id",element.id)
        end
        
        def redefine
          define class_variable_get(:"@@#{self.name.underscore}_element_data")
        end
      
        def element
          Element.find_by(id: class_variable_get(:"@@#{self.name.underscore}_element_id"))
        end
      
      end
      
      def element
        element_id = self.class.class_variable_get(:"@@#{self.class.name.underscore}_element_id")
        Element.find_by(id: element_id)      
      end
      
      included do
        default_scope -> { where(element_id: class_variable_get(:"@@#{self.name.underscore}_element_id")) }  
      end

    end
  end
end