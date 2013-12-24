describe :plv8 do
  it "queries json data" do
    Element.create!(fixture(:elements,:user))
    Element.json_query(:find_by, "string", :name, "=", "User").must_equal Element.first
  end
  it "finds by json data" do
    Element.create!(fixture(:elements,:user))
    Element.json_find_by(:name, "User").must_equal Element.first
  end
end