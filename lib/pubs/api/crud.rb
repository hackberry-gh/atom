require 'active_support/concern'
module Pubs
  module Api
    module CRUD

      extend ActiveSupport::Concern

      LIMIT = 100

      included do

        def self.plural_path
          @plural_path ||= self.name.tableize
        end

        def self.singular_path
          @singular_path ||= plural_path.singularize
        end

        get "/#{plural_path}" do
          model.array_to_json filter(paginate(model.all)).to_sql
        end

        get "/#{singular_path}" do
          model.row_to_json record(:to_sql)
        end

        post "/#{plural_path}" do
          model.create!(params["create"]).to_json
        end

        put "/#{singular_path}" do
          record = self.record
          record.update!(params["update"])
          record.to_json
        end

        patch "/#{singular_path}" do
          record.json_update(params["update"])
        end

        delete "/#{singular_path}" do
          record.destroy!.to_json
        end

      end

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