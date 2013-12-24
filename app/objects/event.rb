class Event < Context
 
  IDLE = 0
  BUSY = 1
  FAILED = 2
  DONE = 3
 
  store_accessor :data, :source_id, :target_id, :status, :check
  validates_presence_of :source_id, :target_id
  
  [:source,:target].each do |rel|
    define_method rel
      (atom = Atom.find_by(id: self.send(:"#{rel}_id"))).try(:becomes,atom.element.class_name)
    end
  end
  
  set_callback :execute, :before do
    self.json_setn(:status, BUSY)
  end
  set_callback :execute, :before do
    self.json_setm(:status, run(self.check) || FAILED)        
  end  
  
  def set_status
    self.status ||= IDLE
  end
  
  def execute
    run_callbacks :execute do
      context.execute
    end
  end

end