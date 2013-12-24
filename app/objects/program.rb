require 'pubs/static_element'
class Program < Atom
  
  include Pubs::StaticElement
 
  store_accessor :data, :name, :slug, :code, :result
  validates_presence_of :name, :name
  
  before_save :set_slug
 
  def run!
    self.result = eval(self.code)
  end  
  
  private
  
  def set_slug
    self.slug = self.name.parameterize
  end
  
end