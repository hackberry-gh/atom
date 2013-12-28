# Context
# ====
# A set of logical rules to test certain conditions
# at any point in time
#
# Properties
# ==========
# look define method
#
# Instance Methods
# ================
# test([binding])
# - runs test and records result
#
# check!
# - runs test without callbacks
#
# run_hook(name)
# - runs hook with given name
# 
# run(code,[binding])
# - runs arbitary ruby code, saves result in db

require 'pubs/objects/static'

class Context < Atom #Program
  
  include Pubs::Objects::Static

  define %(
  name: Context
  group: contexts
  primary_key: slug
  attributes:
    static: Boolean
    name: String
    slug: String
    conditions: String
    result: String
    error: String
    started_at: DateTime
    finished_at: DateTime
    run_at: Integer
    hooks: Object
  validations:
    validates_presence_of: ':name, :conditions'
  callbacks:
    before_save: ':set_slug'
    after_initialize: ':parse_run_at'
  )

  define_callbacks :test

  [:before,:after].each do |event|

      define_method :"#{event}_test" do
        run_hook(:"#{event}_test")
      end
      set_callback :test, event, :"#{event}_test"

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
  
  def run code, binding = nil
    begin
      result = eval(code, binding)
      self.json_update(result: result || :nil)
      result
    rescue Exception => e
      self.json_update(error: e.message+"\n----\n"+e.backtrace.join("\n"))
      return false
    end
  end

  private

  def set_slug
    self.slug = self.name.parameterize
  end

  def parse_run_at
    return if self.run_at.is_a?(Integer)
    self.run_at = (self.run_at.is_a?(String) ? Time.send(:eval,self.run_at) : Time.now).to_i
  end
  
  # def ensure_run_at_in_the_feature
  #   self.errors.add(:run_at, "Must be in the future") if self.run_at <= Time.now.to_i
  # end

end