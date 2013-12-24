describe :context do

  it "runs arbitary code with set of rules" do
    ctx = Context.create!(fixture(:contexts,:truman))
    Context.ready(1.second).count.must_equal 0
    sleep(1)
    Context.ready(1.second).count.must_equal 1
    Context.ready(1.second).map(&:test)
    ctx.reload.result.must_equal true
  end

  it "not runs if test fails" do
    ctx = Context.create!(fixture(:contexts,:failing))
    Context.ready(1.second).map(&:test)
    ctx.reload.result.must_equal nil
  end

end