describe :element do
  
  it "holds element type information and presents it's object after save!" do
    
    Element.create!(fixture(:elements,:user))
    Element.first.name.constantize.must_equal User
    
  end
  
  it "cannot be saved without name and attributes" do
    -> { Element.create! }.must_raise ActiveRecord::RecordInvalid
  end
  
  
  
end