require 'active_support/concern'

module Pubs
  module PLV8
    
    extend ActiveSupport::Concern
    
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
    
  end
end