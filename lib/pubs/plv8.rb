require 'active_support/concern'

module Pubs
  module PLV8

    extend ActiveSupport::Concern
    #include ActiveRecord::Sanitization::ClassMethods

    PLV8_METHODS = %w(string
    int
    int_array
    float
    bool
    date
    increment
    decrement
    set_numeric
    set
    update
    push
    add_to_set
    pull
    data).freeze

    EQ = "=".freeze
    ILIKE = "ilike".freeze
    LT = "<".freeze
    LTE = "<=".freeze
    GT = ">".freeze
    GTE = ">=".freeze
    NEQ = "!=".freeze


    module ClassMethods

      def json_where key, value, operator = EQ, plv8_method = PLV8_METHODS[0]
        json_query :where, plv8_method, key, operator, value
      end

      def json_find_by key, value, plv8_method = PLV8_METHODS[0]
        json_query :find_by, plv8_method, key, EQ, value
      end

      def json_query method, plv8_method, key, operator, value
        raise RuntimeError, "#{plv8_method} not defined" unless PLV8_METHODS.include?(plv8_method)
        self.send method, "json_#{plv8_method}(#{json_store_attribute},?) #{operator} ?", key, value
      end

      def json_store_attribute
        self.name == "Element" ? :meta : :data
      end

    end

    def json_setn key, number
      json_update_column key,number,PLV8_METHODS[8]
    end

    def json_set key, string
      json_update_column key,string,PLV8_METHODS[9]
    end

    def json_update key, json
      json_update_column key, json.to_json, PLV8_METHODS[10]
    end

    def json_push dotted_key, json
      json_update_column dotted_key, json.to_json, PLV8_METHODS[10]
    end

    def json_update_column key, value, plv8_method
      # update = self.class.send(:sanitize_sql_for_assignment,["json_#{plv8_method}(#{self.class.json_store_attribute},?,?)",key,value])
      update = "json_#{plv8_method}(#{self.class.json_store_attribute},#{self.class.sanitize(key)},#{self.class.sanitize(value)})"
      result = self.class.connection.exec_query("UPDATE #{self.class.table_name} SET #{self.class.json_store_attribute} = #{update} WHERE id = '#{self.id}' RETURNING json_string(#{self.class.json_store_attribute},'#{key}') AS #{key}")
      self.send(:"#{key}=",result.first.to_hash[key.to_s])
    end

  end
end