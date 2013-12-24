require 'active_support/concern'
module Pubs
  module StaticElement
    extend ActiveSupport::Concern
    
    module ClassMethods
      
      def element_data
        <<-YAML
        name: #{self.name}
        group: #{self.name.tableize}
        primary_key: id
        attributes: 
          static: Boolean
        YAML
      end
      
      def find_or_create_element
        Element.json_find_by(:name, self.name) || Element.create!(YAML::load(self.element_data))
      end
      
    end
    
    included do
      after_initialize :ensure_element
    end
    
    private
  
    def ensure_element
      self.element ||= self.class.find_or_create_element
      self.element_id ||= self.element.id
    end
    
    def atom_code
      self.class.atom_code
    end
    
  end
end