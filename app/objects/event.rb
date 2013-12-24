require 'pubs/objects/static'

class Event < Atom

  include Pubs::Objects::Static

  IDLE = 0
  BUSY = 1
  FAILED = 2
  DONE = 3

  store_accessor :data, :source_id, :target_id, :context_id, :program_id, :status

  def self.element_data
    <<-YAML
    name: #{self.name}
    group: #{self.name.tableize}
    primary_key: id
    attributes:
      static: Boolean
      source_id: String
      target_id: String
      context_id: String
      program_id: String
      status: Integer
    YAML
  end
  
  default_scope -> { where(element_id: element.id) }  

  validates_presence_of :source_id, :target_id, :context_id, :program_id

  after_create :add_to_sequence
  after_initialize :set_status

  [:source,:target,:context,:program].each do |rel|
    define_method rel do
      (atom = Atom.find_by(id: self.send(:"#{rel}_id"))).try(:becomes,atom.element.class_name.constantize)
    end
  end

  define_callbacks :trigger

  set_callback :trigger, :before do
    self.json_update(status: BUSY)
    context.run_hook :before
  end

  set_callback :trigger, :after do
    check = begin
      if context.check! binding
        context.run_hook(:done)
        DONE
      else
        context.run_hook(:failed)
        FAILED
      end
    end
    self.json_update(status: check)
    
    remove_from_sequence
    
    context.run_hook :after 
  end

  def set_status
    self.status ||= IDLE
  end

  def trigger
    return if self.status != IDLE
    
    run_callbacks :trigger do
      if context.test binding
        program.execute binding
      end
    end
  end
  
  def notify
    diff = context.run_at - Time.now.to_i
    if diff > 0
      puts "--> timered #{diff}"
      EM.add_timer(diff){ trigger }
    else
      trigger
    end  
  end

  def sequence
    Sequence.fetch(context.run_at)
  end

  def add_to_sequence
    sequence.push self.id
  end
  
  def remove_from_sequence
    sequence.push self.id
  end

end