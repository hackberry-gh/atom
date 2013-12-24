require 'pubs/objects/static'

class Program < Atom

  include Pubs::Objects::Static

  def self.element_data
    <<-YAML
    name: #{self.name}
    group: #{self.name.tableize}
    primary_key: slug
    attributes:
      static: Boolean
      name: String
      slug: String
      code: String
      result: String
      error: String
      started_at: DateTime
      finished_at: DateTime
    YAML
  end

  default_scope -> { where(element_id: element.id) }  

  store_accessor :data, :name, :slug, :code, :result, :error, :started_at, :finished_at
  validates_presence_of :name, :code
  define_callbacks :execute

  set_callback :execute, :before do
    self.json_update(started_at: Time.now)
  end

  set_callback :execute, :before do
    self.json_update(finished_at: Time.now)
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