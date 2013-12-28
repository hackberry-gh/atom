describe :element do
  
  it "holds element type information and presents it's object after save!" do
    Element.delete_all
    Element.create!(fixture(:elements,:user))
    Element.first.name.constantize.must_equal User
    
  end
  
  it "cannot be saved without name and attributes" do
    -> { Element.create! }.must_raise ActiveRecord::RecordInvalid
  end
  
  it "determines atom's behaviour" do
    Element.create!(fixture(:elements,:user))
    -> {User.create!}.must_raise ActiveRecord::RecordInvalid
  end
  
  it "counts atoms" do
    Element.create!(fixture(:elements,:user))
    user1 = User.create!(fixture(:atoms,:user))    
    user2 = User.create!(fixture(:atoms,:user2))        
    User.count.must_equal 2
  end
  
  it "validate primary key" do
    Element.create!(fixture(:elements,:user))
    user1 = User.create!(fixture(:atoms,:user))    
    -> { User.create!(fixture(:atoms,:user)) }.must_raise ActiveRecord::RecordInvalid
    
  end
  
  it "should serialize nicely" do
    json = Element.create!(fixture(:elements,:counter)).to_json
    JSON.parse(json)["name"].must_equal "Counter"
  end
  
  it "returns json from postgresql" do
    Element.delete_all
    Element.create!(fixture(:elements,:counter))
    json = Element.row_to_json(Element.where(id: Element.first.id).select(:id,:meta,:atoms_count).limit(1).to_sql)
    json.must_equal Element.first.raw_json(except:["created_at","updated_at"])
  end
  
end