# Program
# ====
#  A ruby program to accomplish certain tasks
#
# Properties
# ==========
# look define method
#
#
# Instance Methods
# ================
# - execute([binding])
#   runs it's code with callbacks
#
# - run(code,[binding])
#   runs arbitary ruby code, saves result in db

require 'pubs/objects/static'

class Program < Atom

  include Pubs::Objects::Static
  
  define %(
  name: Program
  group: programs
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
  validations:
    validates_presence_of: ':name, :code'
  callbacks:
    before_save: ':set_slug'
  )
  
  define_callbacks :execute

  set_callback :execute, :before do
    json_update(started_at: Time.now)
  end

  set_callback :execute, :after do
    json_update(finished_at: Time.now)
  end

  def execute binding = nil
    run_callbacks :execute do
      run(self.code, binding)
    end
  end

  def run code, binding = nil
    self.result = begin 
      result = eval(code, binding)
      self.json_update(result: result || :nil)
      result
    rescue Exception => e
      self.json_update(error: e.message+"\n----\n"+e.backtrace.join("\n"))
      false
    end
  end

  private

  def set_slug
    self.slug = self.name.parameterize
  end

end