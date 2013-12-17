describe :element do
  
  it "holds element type information and presents it's object after save!" do
    
    Element.create!({
      name: "User",
      group: "users",
      primary_key: "email",
      attributes: {
        email: String,
        first_name: String,
        last_name: String
      },
      validations: {
        validates_presence_of: %(:email)
      }
    })
    Element.first.name.constantize.must_equal User
    
  end
  
  it "cannot be saved without name and attributes" do
    -> { Element.create! }.must_raise ActiveRecord::RecordInvalid
  end
  
  
  
end