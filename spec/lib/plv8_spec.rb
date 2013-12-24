describe :plv8 do


  it "replace where and find_by with json conditions" do
    Element.create!(fixture(:elements,:user))
    Element.where(name: "User").count.must_equal 1
    Element.find_by(name: "User").must_equal Element.first
  end

  it "dot notation works" do
    Element.create!(fixture(:elements,:article))
    ar = Article.create!(fixture(:atoms,:article))
    Article.where("i18n.en.title" => "Article").count.must_equal 1
    Article.find_by("i18n.de.title" => "Artikel").wont_equal nil
  end

  it "selects only given fields" do
    Element.create!(fixture(:elements,:user))
    # ap Element.connection.execute("SELECT json_select(meta,'name') as name FROM elements").entries
    JSON.parse(Element.json_query("name,group,attributes")[0]["elements"]).must_equal ["User","users",
      {"email" => "String","first_name" => "String", "last_name" => "String"}]
  end

  it "update json data" do
    Element.create!(fixture(:elements,:article))
    ar = Article.create!(fixture(:atoms,:article))
    ar.json_update(i18n: {en: {title: "BONANZA"}})
    ar.reload.title.must_equal "BONANZA"
  end

end