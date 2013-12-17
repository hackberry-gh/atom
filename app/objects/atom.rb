# Atom
# ====
# An instance of Element with data!
# If Element is the model then Atom is the record.
#
# Properties
# ==========
# - data, JSON

class Atom < ActiveRecord::Base
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