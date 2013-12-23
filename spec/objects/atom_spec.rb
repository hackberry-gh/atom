describe :atom do
  
  it "should be instance of it's elements type" do
    
    element = Element.create!(fixture(:elements,:user))
    user = User.create(fixture(:atoms,:user))
    user.element.must_equal element
    
  end
  
  
end