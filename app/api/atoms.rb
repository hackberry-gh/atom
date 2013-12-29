# Atoms API
# ============
#
# GET /atoms
# -------------
# Retrives all atoms
# 
# Params:
# - element:String | element_id:UUID, [page:Integer], [limit[100]:Integer], [filter:Object]
#
# Example:
# HTTP GET http://atom.pubs.io/atoms?page=1&limit=50&filter[name]=user
#
#
# GET /atom
# -------------
# Retrives single atom
# 
# Params:
# - element:String | element_id:UUID, find_by:Object | id:UUID | field:value
#
# Example:
# HTTP GET http://atom.pubs.io/atoms?id=usk11202
#
#
# POST /atoms
# -------------
# Retrives single atom
# 
# Params:
# - element:String | element_id:UUID, create:Object
#
#
# PUT /atom
# -------------
# Updates an atom with full callbacks and returning object
# 
# Params:
# - element:String | element_id:UUID, find:Object, create:Object
#
#
# PATCH /atom
# -------------
# Updates an atom without callbacks not validations and returning id
# 
# Params:
# - element:String | element_id:UUID, find:Object, create:Object
#
#
# DELETE /atom
# -------------
# Destroys an atom
# 
# Params:
# - element:String | element_id:UUID, find:Object

require 'pubs/api'
require 'pubs/api/crud'
require 'pubs/api/access_control'
class Atoms < Pubs::API
  include Pubs::Api::CRUD
  use Pubs::Api::AccessControl    
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
    else
      error! 404  
    end
  end
  
end