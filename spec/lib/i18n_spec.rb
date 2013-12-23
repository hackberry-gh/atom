describe :I18n do
  
  it "should read localised spesification of elements" do        
    element = Element.create!(fixture(:elements,:multi_user))
    element.validations.values.must_equal [":email"]
    
    I18n.locale = :de   
    element.validations.values.must_equal [":email, :phone"]
    
  end
  
  it "should read localised content when it's available" do        
    element = Element.create!(fixture(:elements,:article))

    atom = Article.create(fixture(:atoms,:article))    
    atom.title.must_equal "Article"
    
    I18n.locale = :de    
    atom.title.must_equal "Artikel"
  end
end