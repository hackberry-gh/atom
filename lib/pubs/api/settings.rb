require 'active_support/concern'
module Pubs
  module Api
    module Settings

      extend ActiveSupport::Concern
      
      
      module ClassMethods
        
        include Pubs::Cache              
        
        def set_key! key, val, ttl = 3600
          cache.set(n("apikeys:#{key}"), val.to_json, ttl)
        end

        def auth_key! key
          cache.get(n("apikeys:#{key}"))
        end    

        def allowed_origins
          (cache.get(n("allowed_origins")) || ENV['ALLOWED_ORIGINS'] || "").split(",")
        end
        
        def allowed_origins=origins
          cache.set(n("allowed_origins"),origins.try(:join,","))
        end        

        def roles
          cache.get(n("roles"))
        end
        
        def roles= roles
          cache.set(n("roles"),roles)
        end        
        
      end
    end
  end
end