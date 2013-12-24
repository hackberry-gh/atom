require 'pubs/static_element'
class Program < Atom
  
  include Pubs::StaticElement
 
  store_accessor :data, :name, :slug, :code, :result
  validates_presence_of :name, :name
 
  def execute
    run(self.code)
  end  
  
  def run code
    self.result = eval(code)
  end
  
  private
  
  def set_slug
    self.slug = self.name.parameterize
  end
  
end