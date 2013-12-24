class Context < Program

  def self.element_data
    <<-YAML
    name: #{self.name}
    group: #{self.name.tableize}
    primary_key: id
    attributes:
      static: Boolean
      run_at: Integer
      hooks: Object
    YAML
  end

  store_accessor :data, :run_at, :hooks

  define_callbacks :test

  scope :ready, -> (span) {
    where(run_at: [GTE, (Time.now - span).to_i], run_at: [LTE, (Time.now + span).to_i])
  }

  [:before,:after].each do |event|
    # [:test,:execute].each do |method|
    [:test].each do |method|
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