require 'pubs/static_element'
class Program < Atom

  include Pubs::StaticElement

  def self.element_data
    <<-YAML
    name: #{self.name}
    group: #{self.name.tableize}
    primary_key: id
    attributes:
      static: Boolean
      name: String
      slug: String
      code: String
      result: String
      error: String
      started_at: Integer
      finished_at: Integer
    YAML
  end

  store_accessor :data, :name, :slug, :code, :result, :error, :started_at, :finished_at
  validates_presence_of :name, :code
  define_callbacks :execute

  set_callback :execute, :before do
    self.json_update(started_at: Time.now.to_i)
  end

  set_callback :execute, :before do
    self.json_update(finished_at: Time.now.to_i)
  end

  def execute binding = nil
    run_callbacks :execute do
      run(self.code, binding)
    end
  end

  def run code, binding = nil
    begin
      if result = eval(code, binding)
        self.json_update(result: result)
      end
      result
    rescue Exception => e
      self.json_update(error: e.message+"\n\n"+e.backtrace.join("\n"))
      return false
    end
  end

  private

  def set_slug
    self.slug = self.name.parameterize
  end

end