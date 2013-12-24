require 'pubs/static_element'

class Event < Atom

  include Pubs::StaticElement

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
      source_id: String
      target_id: String
      context_id: String
      program_id: String
      status: Integer
    YAML
  end

  validates_presence_of :source_id, :target_id, :context_id, :program_id

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
    context.run_hook :after
  end

  def set_status
    self.status ||= IDLE
  end

  def trigger
    run_callbacks :trigger do
      if context.test binding
        program.execute binding
      end
    end
  end



end