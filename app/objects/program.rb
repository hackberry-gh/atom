require 'pubs/static_element'
class Program < Atom

  include Pubs::StaticElement

  store_accessor :data, :name, :slug, :code, :result, :error, :started_at, :finished_at
  validates_presence_of :name, :code
  define_callbacks :execute

  set_callback :execute, :before do
    self.json_setn(:started_at, Time.now.to_i)
  end

  set_callback :execute, :before do
    self.json_setn(:finished_at, Time.now.to_i)
  end

  def execute binding = nil
    run_callbacks :execute do
      run(self.code, binding)
    end
  end

  def run code, binding = nil
    begin
      if result = eval(code, binding)
        self.json_set(:result, result)
      end
      result  
    rescue Exception => e
      self.json_set(:error, e.backtrace.join("\n"))
      return false
    end
  end

  private

  def set_slug
    self.slug = self.name.parameterize
  end

end