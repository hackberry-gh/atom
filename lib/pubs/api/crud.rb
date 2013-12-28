require 'active_support/concern'
module Pubs
  module Api
    module CRUD
      
      extend ActiveSupport::Concern
      
      LIMIT = 100
          
      included do
        
        def self.plural_path
          @@plural_path ||= self.name.tableize
        end
      
        def self.singular_path
          @@singular_path ||= plural_path.singularize
        end
        
        get "/#{plural_path}" do; all; end
        get "/#{singular_path}" do; find; end  
        post "/#{plural_path}" do; create.to_json; end    
        put "/#{singular_path}" do; update.to_json; end
        patch "/#{singular_path}" do; patch; end        
        delete "/#{singular_path}" do; delete.to_json; end
        
      end
      
      def all
        # model.array_to_json filter(paginate(model.select(*fields))).to_sql
        model.array_to_json filter(paginate(model.all)).to_sql        
      end
  
      def find
        # model.row_to_json model.select(*fields).where(params["find_by"]).limit(1).to_sql
        model.row_to_json record(:to_sql)
      end
  
      def create
        model.create!(params["create"])
      end
  
      def update
        (rec=record).update!(params["update"])
        rec
      end
      
      def patch
        record.json_update(params["update"])
      end
  
      def delete
        record.destroy!
      end
      
      # def fields
      #   fields = params["fields"] || (is_element? ? model.stored_attributes[:meta] : model.element.pubic_attributes)
      #   fields = fields.join(",") if fields.is_a?(Array)
      #   store = is_element? ? :meta : :data
      #   if fields.include?(",")
      #     as = self.class.plural_path
      #     fields = "json_select_all(#{store},#{model.sanitize(fields)})"
      #   else
      #     as = fields
      #     fields = "json_select(#{store},#{model.sanitize(fields)},true)"
      #   end
      # end
  
      def filter collection
        params["filter"] ? collection.where(params["filter"]) : collection
      end
  
      def paginate collection
        collection.limit(limit).offset(offset)
      end
  
      def limit
        params["limit"] || LIMIT
      end
  
      def offset
        [(params["page"] ||= 1), 1].max - 1
      end
      
      def find_by
        params["find_by"] || { "id" => params["id"] }
      end
      
      def record req = :first
        model.where(find_by).limit(1).send(req)
      end
  
      def model
        self.class.singular_path.classify.constantize
      end
      
      def is_element?
        self.class.singular_path == "element"
      end
      
    end
  end
end