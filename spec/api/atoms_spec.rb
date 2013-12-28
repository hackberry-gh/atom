require 'goliath'
require 'api/atoms'

describe :atoms do
  let(:api_options) { {:verbose => true, :log_stdout => true, :config => "config/server.rb" } }
  let(:guest_head) { {'X-Api-Key' => 'guest'} }

  it 'renders 200 for /status' do
    with_api(Atoms, api_options) do
      get_request(:path => '/status', head: guest_head) do |c|
        c.response_header.status.must_equal 200
      end
    end
  end

  it 'renders all atoms for /atoms' do
    element = Element.create!(fixture(:elements,:user))
    user = User.create!(fixture(:atoms,:user))
        
    with_api(Atoms, api_options) do
      get_request(:path => '/atoms', head: guest_head, body: {"element" => "User"}) do |c|
        c.response_header.status.must_equal 200
        JSON.parse(c.response).count.must_equal User.all.count
      end
    end
  end
  
  it 'respects i18n settings of element' do
    I18n.available_locales = [:en,:de]
    element = Element.create!(fixture(:elements,:multi_user))
    Compound.register_element element
        
    with_api(Atoms, api_options) do
      post_request(:path => '/atoms', head: guest_head, body: {element: "user", locale: "de", create: fixture(:atoms,:user)}) do |c|
        c.response_header.status.must_equal 406
        JSON.parse(c.response).must_equal({"phone" => ["can't be blank"]})
      end
    end
  end
  
  it 'respects i18n settings of element' do
    I18n.available_locales = [:en,:de]
    element = Element.create!(fixture(:elements,:multi_user))
    Compound.register_element element
        
    with_api(Atoms, api_options) do
      post_request(:path => '/atoms', head: guest_head, body: {element: "user", locale: "de", create: fixture(:atoms,:user3)}) do |c|
        c.response_header.status.must_equal 200
        JSON.parse(c.response)['id'].must_equal User.order("id").last.id
      end
    end
  end
  
  it "respescts i18n content" do
    I18n.available_locales = [:en,:de]
    element = Element.create!(fixture(:elements,:article))
    Compound.register_element element
    atom = Article.create(fixture(:atoms,:article))    
        
    with_api(Atoms, api_options) do
      get_request(:path => '/atom', head: guest_head, body: {element: "article", locale: "de", id: atom.id}) do |c|
        c.response_header.status.must_equal 200
        JSON.parse(c.response)['title'].must_equal "Artikel"
      end
    end
  end
  
  it "respescts i18n content on update" do
    I18n.available_locales = [:en,:de]
    element = Element.create!(fixture(:elements,:article))
    Compound.register_element element
    atom = Article.create(fixture(:atoms,:article))    
        
    with_api(Atoms, api_options) do
      put_request(:path => '/atom', head: guest_head, body: {element: "article", locale: "de", id: atom.id, update:{title:"ZORZOR"}}) do |c|
        c.response_header.status.must_equal 200
        JSON.parse(c.response)['title'].must_equal "ZORZOR"
        I18n.locale = :en
        Article.first.title.must_equal "Article"
      end
    end
    
  end
  
end