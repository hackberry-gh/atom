describe :compound do
  it "proxies class methods to member classes" do
    
    I18n.available_locales = [:en,:de]

    class MemberEn
      def name
        "Richard"
      end
    end
    
    class MemberDe
      def name
        "Hans"
      end
    end
    
    class Member < Compound
      register_locales
    end
    
    I18n.locale = :en
    richard = Member.new
    richard.name.must_equal "Richard"
    richard.class.must_equal MemberEn
    
    I18n.locale = :de
    hans = Member.new
    hans.name.must_equal "Hans"
    hans.class.must_equal MemberDe
    
  end
end

describe :compound_locales do
  
  it "unifies atom classes through localised element spesification" do
    I18n.available_locales = [:en,:de]
    I18n.locale = I18n.default_locale
    
    element = Element.create(fixture(:elements,:multi_user))          

    user = User.create(email: "test@test.com")
    user.persisted?.must_equal true

    
    I18n.locale = :de
    user = User.create(email: "test2@test.com")
    user.persisted?.must_equal false    

    
  end
end