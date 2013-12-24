# Atom
# ====
# An instance of Element with data!
# If Element is the model then Atom is the record.
#
# Properties
# ==========
# - data, JSON
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
      key.split(".").inject(self.data){ |data,key| data.try(:[],key) }
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