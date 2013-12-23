# Compound
# =======
# Mix with Proxy and Factory patterns to share common tasks with different settings
# based on i18n locale
# basically proxies class methods to available member classes
# in other words unified interface for same element atoms
#
# Example
# =======
# class User < Compound
#   register_locales
# end
# I18n.locale = :de
# user_de = User.create!(params_for_de) 
# I18n.locale = :en
# user_en = User.create!(params_for_en)

class Compound
  
  class << self
    
    def register_element element
      element.send :pop!
      Object.module_eval "class #{element.class_name} < Compound; end"      
      self.atom_class = element.class_name.safe_constantize
      element.class_eval do
        def class_name locale = I18n.locale
          "#{self.name}::#{locale.to_s.classify}"
        end
      end
      I18n.available_locales.each do |locale|
        I18n.with_locale(locale) do
          element.send :gen!
        end
      end
      self.register_locales
    end
    
    def register_locales 
      members = self.members
      I18n.available_locales.each do |locale|
        if atom_class.const_defined?(locale_class_name(locale))
          members[locale] = class_name(locale).safe_constantize 
        end
      end
      self.members = members
    end
    
    def atom_class
      @@atom_class ||= self.name.safe_constantize
    end
    
    def atom_class=atom_class
      @@atom_class=atom_class
    end

    def locale_class_name locale = I18n.locale
      begin
        class_variable_get(:"@@#{locale}") 
      rescue 
        class_variable_set(:"@@#{locale}",locale.to_s.classify)
      end
    end
    
    def class_name locale = I18n.locale
      "#{atom_class}::#{locale_class_name(locale)}"
    end
    
    def members
      @@members ||= {}
    end
    
    def members= members
      @@members = members
    end
    
    def new *args
      return members[I18n.locale].new(*args)
    end
    
    def method_missing(name,*args,&block)
      return super(name,*args,&block) if (klass = members[I18n.locale]).nil?
      klass.send(name,*args,&block)
    end
    
  end
  
end