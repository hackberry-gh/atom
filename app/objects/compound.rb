# Compound
# =======
# Mix with Proxy and Factory patterns to share common tasks with different settings
# basically proxies class methods to available member class 
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
    
    def register_locales
      members = self.members
      I18n.available_locales.each do |locale|
        class_name = class_name(locale)
        if Object.const_defined?(class_name)
          members[class_name] = class_name.constantize 
        end
      end
      self.members = members
    end
    
    def class_name locale = I18n.locale
      "#{self.name}#{locale.to_s.classify}"
    end
    
    def members
      @@members ||= {}
    end
    
    def members= members
      @@members = members
    end
    
    def new *args
      return members[class_name].new(*args)
    end
    
    def method_missing(name,*args,&block)
      return super(name,*args,&block) if (klass = members[class_name]).nil?
      klass.send(name,*args,&block)
    end
    
  end
  
end