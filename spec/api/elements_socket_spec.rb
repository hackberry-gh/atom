require 'goliath'
require 'api/elements'

describe :elements do


  let(:api_options) { {:verbose => true, :log_stdout => true, :config => "config/server.rb" } }
  let(:guest_head) { {'X-Api-Key' => 'guest'} }

  it 'renders all elements for /elements' do
    with_api(Elements, api_options) do
      ws_client_connect("/ws/elements") do |c|
        c.send({method: "GET", head: guest_head}.to_json)
        JSON.parse(JSON.parse(c.receive.data).last).count.must_equal Element.all.count
      end
    end
  end

  it 'renders one element for /element' do

    with_api(Elements, api_options) do
      Element.delete_all
      Element.create!(fixture(:elements,:user))
      ws_client_connect("/ws/element") do |c|
        c.send({method: "GET", head: guest_head, body: {id: Element.first.id}}.to_json)
        JSON.parse(JSON.parse(c.receive.data).last).keys.must_equal JSON.parse(Element.first.raw_json).keys
      end
    end
  end

  it 'renders one element for /element with find_by' do

    with_api(Elements, api_options) do
      Element.delete_all
      Element.create!(fixture(:elements,:user))
      ws_client_connect("/ws/element") do |c|
        c.send({method: "GET", head: guest_head, body: {find_by: {name: Element.first.name}}}.to_json)
        JSON.parse(JSON.parse(c.receive.data).last).keys.must_equal JSON.parse(Element.first.raw_json).keys
      end
    end
  end


  it 'creates a new element with given data' do

    with_api(Elements, api_options) do
      Element.delete_all

      ws_client_connect("/ws/elements") do |c|
        c.send({method: "POST", head: guest_head,  body: {create: fixture(:elements,:user)}}.to_json)

        JSON.parse(c.receive.data).last.must_equal Element.first.to_json
      end

    end

  end

  it 'updates a element with given data' do

    with_api(Elements, api_options) do
      Element.delete_all
      e = Element.create!(fixture(:elements,:user))
      ws_client_connect("/ws/element") do |c|
        c.send({method: "PUT", head: guest_head,  body: {find_by: { id: e.id}, update: {name: "BONANZA"}}}.to_json)

        JSON.parse(JSON.parse(c.receive.data).last)["name"].must_equal "BONANZA"
      end
    end
  end

  it 'patches a element with given data' do

    with_api(Elements, api_options) do
      Element.delete_all
      e = Element.create!(fixture(:elements,:user))
      ws_client_connect("/ws/element") do |c|
        c.send({method: "PATCH", head: guest_head,  body: {find_by: { id: e.id}, update: {name: "BONANZA"}}}.to_json)
        JSON.parse(c.receive.data).last.must_equal e.id
        e.reload.name.must_equal "BONANZA"
      end
    end
  end

  it 'destroys a element ' do

    with_api(Elements, api_options) do
      Element.delete_all
      e = Element.create!(fixture(:elements,:user))

      ws_client_connect("/ws/element") do |c|
        c.send({method: "DELETE", head: guest_head,  body: {id: e.id}}.to_json)
        JSON.parse(JSON.parse(c.receive.data).last)["id"].must_equal e.id 
        -> { User }.must_raise NameError
      end
    end
  end


end