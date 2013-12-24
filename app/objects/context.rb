class Context < Program
    
  store_accessor :data, :run_at, :hooks
  
  define_callbacks :test
  
  scope :ready, -> (span) {
    json_where(:run_at, (Time.now - span).to_i, GTE, PLV8_METHODS[1]).
    json_where(:run_at, (Time.now + span).to_i, LTE, PLV8_METHODS[1])
  }
  
  [:before,:after].each do |event|
    [:test,:execute].each do |method|
      define_method :"#{event}_#{method}" do
        run_hook(:"#{event}_#{method}")
      end
      set_callback method, event, :"#{event}_#{method}"
    end
  end
  
  after_initialize :parse_run_at
  
  attr_accessor :conditions
  
  def conditions
    self.code
  end
  
  def conditions=conditions
    self.code=conditions
  end
  
  def test binding = nil
    run_callbacks :test do
      run(self.conditions[:test], binding)
    end
  end
  
  def check! binding = nil
    run(self.conditions[:result], binding)
  end
  
  def run_hook name
    if hook = self.try(:hooks).try(:[],name) 
      run(hook)
    end
  end
  
  private
  
  def parse_run_at
    self.run_at = self.run_at.is_a?(String) ? Time.send(:eval,self.run_at).to_i : Time.now.to_i
  end
 
  
end