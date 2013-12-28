require 'goliath'
require 'api/elements'

describe :elements do

 
  let(:api_options) { {:verbose => true, :log_stdout => true, :config => "config/server.rb" } }
  let(:guest_head) { {'X-Api-Key' => 'guest'} }

  it 'renders 200 for /status' do
    with_api(Elements, api_options) do
      get_request(:path => '/status', head: guest_head) do |c|
        c.response_header.status.must_equal 200
      end
    end
  end
  
  it 'renders all elements for /elements' do
    with_api(Elements, api_options) do
      get_request(:path => '/elements', head: guest_head) do |c|
        c.response_header.status.must_equal 200
        JSON.parse(c.response).count.must_equal Element.all.count
      end
    end
  end
  
  it 'renders one element for /element' do
    
    with_api(Elements, api_options) do
      Element.delete_all
      Element.create!(fixture(:elements,:user))      
      get_request(:path => '/element', head: guest_head, body: {id: Element.first.id}) do |c|
        c.response_header.status.must_equal 200
        JSON.parse(c.response).keys.must_equal JSON.parse(Element.first.raw_json).keys
      end
    end
  end
  
  it 'renders one element for /element with find_by' do
    
    with_api(Elements, api_options) do
      Element.delete_all
      Element.create!(fixture(:elements,:user))      
      get_request(:path => '/element', head: guest_head, body: {find_by: {name: Element.first.name}}) do |c|
        c.response_header.status.must_equal 200
        JSON.parse(c.response).keys.must_equal JSON.parse(Element.first.raw_json).keys
      end
    end
  end
  
  
  it 'creates a new element with given data' do
    
    with_api(Elements, api_options) do
      Element.delete_all
      post_request(:path => '/elements', head: guest_head, body: {create: fixture(:elements,:user)}) do |c|
        c.response_header.status.must_equal 200
        c.response.must_equal Element.first.to_json
      end
    end
  end
  
  it 'updates a element with given data' do
    
    with_api(Elements, api_options) do
      Element.delete_all
      e = Element.create!(fixture(:elements,:user))            
      put_request(:path => '/element', head: guest_head, body: {find_by: { id: e.id}, update: {name: "BONANZA"}}) do |c|       
        c.response_header.status.must_equal 200
        JSON.parse(c.response)["name"].must_equal "BONANZA"
      end
    end
  end
  
  it 'patches a element with given data' do
    
    with_api(Elements, api_options) do
      Element.delete_all
      e = Element.create!(fixture(:elements,:user))            
      patch_request(:path => '/element', head: guest_head, body: {find_by: { id: e.id}, update: {name: "BONANZA"}}) do |c|       
        c.response_header.status.must_equal 200
        Element.first.name.must_equal "BONANZA"
      end
    end
  end
  
  it 'destroys a element ' do
    
    with_api(Elements, api_options) do
      Element.delete_all
      e = Element.create!(fixture(:elements,:user))            
      delete_request(:path => '/element', head: guest_head, body: { id: e.id} ) do |c|       
        c.response_header.status.must_equal 200
        -> { User }.must_raise NameError
      end
    end
  end
  
  
  # it "socks" do
# 
#     with_api(Elements, api_options) do |api|
# 
#       ws_client_connect("/ws/elements") do |c|
#         c.send({method: "GET", head: guest_head}.to_json)
#          JSON.parse(c.receive.data).must_equal [200,{"Content-Type" => "application/json"},Element.all.to_json]
#       end
# 
#     end
#   end
#   
 
end