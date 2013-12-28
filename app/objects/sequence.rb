# Sequence
# ========
# A group of events to run or doing something else
#
# ClassMethods
# ===========
# get([time=Time.now])
# - finds current sequence
#
# fetch([time=Time.now])
# - finds or creates new sequence by giving time
#
# events([ids=self.event_ids])
# - retrives all events with given ids
#
# push(Event)
# pushes event at the end of sequence
#
# pull(Event)
# removes event from sequence
#
# TODO: move database backend to memcache!!!

require 'pubs/objects/static'

class Sequence < Atom

  include Pubs::Objects::Static

  define %(
  name: Sequence
  group: sequences
  primary_key: timestamp
  attributes:
    static: Boolean
    event_ids: Array
    timestamp: Integer
  validations:
    validates_presence_of: ':timestamp'
  )
  
  MINUTE = 1.minute.freeze
  
  def self.get time = Time.now
    self.find_by(timestamp: time.beginning_of_minute.to_i)
  end
  
  def self.fetch time
    time = (Time.at(time).beginning_of_minute + MINUTE)
    self.get(time) || self.create!(timestamp: time.to_i)
  end
  
  def events(ids = self.event_ids)
    Event.where(id: ids)
  end
  
  def push event
    json_push :event_ids, (event.try(:id) || event)
  end
  
  def pull event
    json_pull :event_ids, (event.try(:id) || event)
    self.destroy if events.empty?
  end
  
end