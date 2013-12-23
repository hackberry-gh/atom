describe :compound do
  it "proxies class methods to member classes" do
    I18n.available_locales = [:en,:de]

    class Member < Compound
      
    end
    
    class Member::En
      def name
        "Richard"
      end
    end
    
    class Member::De
      def name
        "Hans"
      end
    end
    
    Member.register_locales
    
    I18n.locale = :en
    richard = Member.new
    richard.name.must_equal "Richard"
    richard.class.must_equal Member::En
    
    I18n.locale = :de
    hans = Member.new
    hans.name.must_equal "Hans"
    hans.class.must_equal Member::De
    
    Member.unregister
    
  end
  
  it "unifies atom classes through localised element spesification" do
    I18n.available_locales = [:en,:de]
    
    element = Element.create(fixture(:elements,:multi_user))          
    
    Compound.register_element element
  
    user = User.create(email: "test@test.com")
    user.persisted?.must_equal true
  
    I18n.locale = :de
    user = User.create(email: "test2@test.com")
    user.persisted?.must_equal false   
     
    User.unregister
  end
  
end