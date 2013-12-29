# Elements API
# ============
#
# GET /elements
# -------------
# Retrives all elements
# 
# Params:
# - [page:Integer], [limit[100]:Integer], [filter:Object]
#
# Example:
# HTTP GET http://atom.pubs.io/elements?page=1&limit=50&filter[name]=user
#
#
# GET /element
# -------------
# Retrives single element
# 
# Params:
# - find_by:Object | id:UUID | field:value
#
# Example:
# HTTP GET http://atom.pubs.io/elements?id=usk11202
#
#
# POST /elements
# -------------
# Retrives single element
# 
# Params:
# - create:Object
#
#
# PUT /element
# -------------
# Updates an element with full callbacks and returning object
# 
# Params:
# - find:Object, create:Object
#
#
# PATCH /element
# -------------
# Updates an element without callbacks not validations and returning id
# 
# Params:
# - find:Object, create:Object
#
#
# DELETE /element
# -------------
# Destroys an element
# 
# Params:
# - find:Object

require 'pubs/api'
require 'pubs/api/crud'
require 'pubs/api/access_control'
class Elements < Pubs::API
  include Pubs::Api::CRUD
  use Pubs::Api::AccessControl  
end