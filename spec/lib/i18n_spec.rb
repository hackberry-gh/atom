describe :I18n do
  it "should read localised content when it's available" do
    element = Element.create(fixture(:elements,:multi_user))    
    I18n.locale = :en
    element.attributes.keys.must_equal %w(email first_name last_name)
    element.validations.values.must_equal [':email']
    I18n.locale = :de    
    element.attributes.keys.must_equal %w(email first_name last_name phone)
    element.validations.values.must_equal [':email, :phone']        
  end
end