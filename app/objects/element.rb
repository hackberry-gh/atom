# Element
# =======
# Basic type of data unit, aka *Model*
# Simple as possible, holds characteristic properties of an Atom
#
# Properties
# ==========
# id: UUID, Uniq ID of an Element Object, Primary Key
# meta: JSON, holds data model information of an Atom Object
# default meta structure is;
# - name, String, name of the element
# - group, String, *optional, plural name of the element, 
# autogenerating if not giving
# - primary_key, String, *optional, uniq primary key, first attribute selecting 
# if not given
# - attributes, JSON, {field_name: 'DataType'}
# - validations, JSON, *optional, {validator: 'parameters'}, ActiveRecord Validatiors
# - callbacks, JSON, *optional, {callback: 'event_name'}, Event Object to notify
# - settings, JSON, *optional, {key: 'value'}, Customisable options
# -- public_attributes map of json representation
# -- csv_attributes to download desired columns as csv
# -- stub_attributes to skip saving data in db
#
# Example
# =======
# Element.create!({
#   name: "User",
#   group: "users",
#   primary_key: "email",
#   attributes: {
#     email: String,
#     first_name: String,
#     last_name: String
#   },
#   validations: {
#     validates_presence_of: %(:email)
#   }
# })
class Element < ActiveRecord::Base
  store_accessor :meta, :name, :group, :primary_key, 
  :attributes, :validations, :callbacks
  
  STUB = "Stub".freeze
  
  validates_presence_of :name, :attributes
  
  before_save :check_naming
  
  after_save :gen!
  
  after_destroy :pop!
  
  attr_accessor :redefine
  
  # NOTE: Don't forget, only first level of json is indifferent accessible!
  def csv_attributes
    @csv_attributes ||= settings.try(:[],:csv_attributes).keys.map(&:to_sym) || recordable_attributes
  end

  def public_attributes
    @public_attributes ||= settings.try(:[],:public_attributes).keys.map(&:to_sym) || recordable_attributes
  end

  def recordable_attributes
    @recordable_attributes ||= attributes.select{|name,type| type != STUB}.keys.map(&:to_sym)
  end

  def stub_attributes
    @stub_attributes ||= attributes.select{|name,type| type == STUB}.keys.map(&:to_sym)
  end
  
  def class_defined?
    Object.const_defined?(self.name)
  end
  
  private
  
  def gen!
    if self.redefine || !class_defined?
      
      self.redefine = false
      
      # Hmm, removing and readding a constant on the fly
      # not sure but a bit scary 
      pop!
    
      # Generate and define new Element Class  
      Object.module_eval <<-CODE
        class #{self.name} < Atom
          default_scope -> { where(element_id: '#{self.id}') }        
        end
      CODE
    
      klass = self.name.constantize

      klass.send :store_accessor, :data, *self.recordable_attributes

      klass.send :attr_accessor, *self.stub_attributes

      %w(validations callbacks).each { |prop| 
      
        next if (hash=self[prop]).nil?
      
        klass.class_eval hash.map{ |k,v| k.to_s + v.to_s }.join("\n")
      
      }
    
      klass
    end
  end
  
  def pop!
    if Object.const_defined? self.name 
      Object.send :remove_const, self.name
    end
  end
  
  def check_naming
    self.group ||= name.tableize
    self.primary_key ||= attributes.keys.first
    self.name = self.name.classify
    self.redefine = self.meta_changed?
  end
  
end