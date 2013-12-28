require 'goliath'
require 'pubs/api'

describe :api do

 
  let(:api_options) { {:verbose => true, :log_stdout => true, :config => "config/server.rb" } }
  let(:guest_head) { {'X-Api-Key' => 'guest'} }

  it 'renders 404 without a path ' do
    with_api(Pubs::API, api_options) do
      get_request(:path => '/', head: guest_head) do |c|
        c.response_header.status.must_equal 404
      end
    end
  end
  
end