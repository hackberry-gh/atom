# Atom
# ====
# An instance of Element with data!
# If Element is the model then Atom is the record.
#
# Properties
# ==========
# - data, JSON

require 'pubs/plv8'

class Atom < ActiveRecord::Base
  
  include Pubs::PLV8
  
  self.abstract_class = true
  
  self.table_name = "atoms"

  belongs_to :element, counter_cache: true

  def to_csv csv_attributes = element.csv_attributes
    csv_attributes.map{ |key|
      key.split(".").inject(self.data){ |data,key| data.try(:[],key) }
    }.to_csv
  end

  def as_json(options = {})
    super({except: [:data], methods: element.public_attributes}.update(options))
  end

end