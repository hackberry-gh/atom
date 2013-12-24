class Context < Program
end

class Context < Program
  
  store_accessor :data, :run_at, :conditions, :hooks
  
  define_callbacks :test, :execute
  
  scope :ready, -> (span) {
    json_where(:run_at, Time.now - span, GTE, PLV8_METHODS[5]).
    json_where(:run_at, Time.now + span, LTE, PLV8_METHODS[5])
  }
  
  [:before,:after].each do |event|
    [:test,:execute].each do |method|
      define_method :"#{event}_#{method}" do
        return unless hook = self.hooks[:"#{event}_#{method}"]
        run(hook)
      end
      set_callback method, event, :"#{event}_#{method}"
    end
  end
  
  def test
    run_callbacks :test do
      run(conditions)
    end
  end
  
  def execute
    return unless test
    run_callbacks :execute do
      super
    end
  end
  
end