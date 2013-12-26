describe :context do

  it "runs arbitary code as test with set of rules and return true" do
    ctx = Context.create!(fixture(:contexts,:truman))
    ctx.test.must_equal true
  end

  it "return false if test fails" do
    ctx = Context.create!(fixture(:contexts,:failing))
    ctx.test.must_equal false
  end

end