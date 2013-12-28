require 'pubs/api'
require 'pubs/api/crud'

class Atoms < Pubs::API
  include Pubs::Api::CRUD
  
  get "/#{plural_path}" do
    if model.element.i18n_attributes.empty?
      model.array_to_json filter(paginate(model.all)).to_sql
    else
      filter(paginate(model.all)).to_json
    end
  end

  get "/#{singular_path}" do
    if model.element.i18n_attributes.empty?    
      model.row_to_json record(:to_sql)
    else
      record.to_json
    end
  end
  
  def model
    if params["element"]
       params["element"].classify.constantize
    elsif params["element_id"]   
      Element.find(params["element_id"]).class_name.constantize 
    end
  end
  
end