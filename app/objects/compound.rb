# Compound
# =======
# Mix with Proxy and Factory patterns to share common tasks with different settings
# based on i18n locale
# basically proxies class methods to available member classes
# in other words unified interface for same element atoms
#
# Class Methods
# =============
# register_element(Element)
# - Generates localised Atom classes of given element, ie: User::En
#
# unregister
# - Removes registered localised classes
#
# register_locales
# - Registers Atom classes for all available locales (via ClassName)
#
# atom_class
# - Determines Element name from ClassName
#
# locale_class_name
# - Localised Atom class name
#
# class_name
# - Compound class name
#
# members
# registered atoms
#
# members=Array
# - sets registeres atoms
#
# new(*args)
# - Creates new localised instance of existing member
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
      atom_class = element.class_name
      Object.module_eval "class #{element.class_name} < Compound; end"      
      element.class_eval do
        alias_method :org_class_name, :class_name
        def class_name locale = I18n.locale
          "#{self.name}::#{locale.to_s.classify}"
        end
        def class_defined?
          Object.const_defined?(self.class_name.demodulize)
        end
        def pop!
          if Object.const_defined? self.class_name.demodulize
            Object.send :remove_const, self.class_name
          end
        end
      end
      I18n.available_locales.each do |locale|
        I18n.with_locale(locale) do
          element.send :gen!
        end
      end
      atom_class.constantize.register_locales
    end
    
    def unregister
      atom_class_name = self.atom_class.name
      self.members.each{|locale,klass| self.atom_class.send :remove_const, locale_class_name(locale)}
      self.members = {}
      Object.send :remove_const, atom_class_name
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
      self.name.safe_constantize
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