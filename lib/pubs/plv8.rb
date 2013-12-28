require 'active_support/concern'

module Pubs
  module PLV8

    extend ActiveSupport::Concern


    # json_string
    # json_int
    # json_int_array
    # json_float
    # json_bool
    # json_date

    # json_select
    # json_select_all

    # json_update
    # json_push
    # json_add_to_set
    # json_pull
    # json_increment
    # json_decrement

    TYPES = {
      "String" => "string",
      "Integer" => "int",
      "Array" => "int_array",
      "Float" => "float",
      "Boolean" => "bool",
      "Date" => "date",
      "DateTime" => "date",
      "Time" => "date",
      "Object" => "object",
    }.freeze

    STRING = "string"

    DISCARD = [:id,:element_id,:created_at,:updated_at,:atoms_count].freeze

    EQ = "=".freeze
    ILIKE = "ilike".freeze
    LT = "<".freeze
    LTE = "<=".freeze
    GT = ">".freeze
    GTE = ">=".freeze
    NEQ = "!=".freeze

    module ClassMethods
      
      def array_to_json sql
        self.connection.select_value("select array_to_json(coalesce(array_agg(row_to_json(t)), '{}')) from (#{sql}) t")
      end
  
      def row_to_json sql
        self.connection.select_value("select row_to_json(t) from (#{sql}) t")
      end

      # def select *fields
      #   super(*fields.map{ |field| json_select(field) })
      # end

      def where *args
        return super(*args) unless args.first.is_a? Hash
        super(*args.map{ |condition| json_condition(condition) })
      end

      def find_by *args
        return super(*args) unless args.first.is_a? Hash
        super(*args.map{ |condition| json_condition(condition) })
      end

      def json_condition condition

        key = condition.keys.first

        return condition if DISCARD.include?(key.to_sym)

        value = condition.values.first
        case value
        when Array
          operator, value = value
        when Hash
          operator, value = value.to_a.flatten
        else
          operator = EQ
        end

        type = self.store == :meta ? STRING : (TYPES[self.element.attributes[key]] || STRING)
        "json_#{type}(#{store},#{sanitize(key)}) #{operator} #{sanitize(value)}"
      end

      def json_query fields, etc = nil, run = true

        fields = fields.join(",") if fields.is_a?(Array)
        if fields.include?(",")
          as = self.table_name
          fields = "json_select_all(#{self.store},#{sanitize(fields)})"
        else
          as = fields
          fields = "json_select(#{self.store},#{sanitize(fields)},true)"
        end

        sql = "SELECT #{fields} AS #{as} FROM #{self.table_name} "
        sql += "#{sanitize(etc)}" if etc
        run ? self.connection.select_values(sql) : sql

      end

      def json_update params, conditions = nil, sync = true
        update = "json_update(#{self.store},#{sanitize(params.to_json)}, #{sync}) "
        json_func update, conditions
      end

      def json_func update, conditions, meth = :select_values #:exec_query
        sql = "UPDATE #{self.table_name} SET #{self.store} = #{update} "
        sql += "WHERE #{(conditions)} " unless conditions.nil?
        sql += "RETURNING *"
        connection.send(meth,sql)
      end

      def store
        @@store = self.name == "Element" ? :meta : :data
      end

    end

    def json_update params, sync = true
      result = self.class.json_update params, json_conditions, sync
      # process_result result
    end

    def json_push key, item
      update = "json_push(#{self.class.store},#{self.class.sanitize(key)},#{self.class.sanitize(item.to_json)}) "
      result = self.class.json_func update, json_conditions
      # process_result result
    end

    def json_pull key, item
      update = "json_pull(#{self.class.store},#{self.class.sanitize(key)},#{self.class.sanitize(item.to_json)}) "
      result = self.class.json_func update, json_conditions
      # process_result result
    end

    def json_increment! key, amount = 1
      update = "json_increment(#{self.class.store},#{self.class.sanitize(key)},#{amount}) "
      result = self.class.json_func update, json_conditions
      # process_result result
    end

    def json_decrement! key, amount = 1
      update = "json_decrement(#{self.class.store},#{self.class.sanitize(key)},#{amount}) "
      result = self.class.json_func update, json_conditions
      # process_result result
    end

    def json_conditions
      @conditions ||= "id = '#{self.id}'"
    end

    def process_result result
      values = result.to_a.first
      result.column_types.each{ |key,oid|
        self.send(:"#{key}=",oid.type_cast(values[key]))
      }
    end

  end
end