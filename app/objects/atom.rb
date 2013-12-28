# Atom
# ====
# Abstract Class for other Atom Classes
# Atoms hold real data of Element types.
#
# Properties
# ==========
# - id, UUID
# - data, JSON
# - created_at, DateTime
# - updated_at, DateTime
#
# Relations
# ==========
# - element, Element
#
# Instance Methods
# ================
# - pkey_name, String
#   custom primary_key field name, can be set from Elemenet
# - pkey, *
#   custom primary_key field value
# - to_csv, String
#   serializes Atom as csv string with headers of Element#settings[:csv_attributes]
# - as_json, String
#   serializes Atom as json string with headers of Element#settings[:public_attributes]

require 'csv'
require 'pubs/plv8'

class Atom < ActiveRecord::Base

  include Pubs::PLV8

  self.abstract_class = true

  self.table_name = "atoms"

  belongs_to :element, counter_cache: true

  validate :uniq_primary_key, if: "pkey_name.present?"

  def pkey_name
    self.element.try(:primary_key).try(:to_sym)
  end

  def pkey
    self.send(self.pkey_name) if self.pkey_name
  end
  
  # Serialization
  
  def to_csv csv_attributes = element.csv_attributes
    csv_attributes.map{ |key|
      key.to_s.split(".").inject(self.data){ |data,key| data.try(:[],key) }
    }.to_csv
  end

  def as_json(options = {})
    super({except: [:data], methods: element.public_attributes}.update(options))
  end

  private
  
  def uniq_primary_key
    errors.add(self.pkey_name, :taken) unless self.class.find_by(self.pkey_name => self.pkey).nil?
  end

end