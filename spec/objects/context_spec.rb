describe :context do
  it "runs arbitary code with set of rules" do
    ctx = Context.create!(fixture(:contexts,:truman).update(run_at: Time.now + 2.seconds))
    Context.ready(1.second).count.must_equal 0
    sleep(1)
    Context.ready(1.second).count.must_equal 1
    Context.ready(1.second).map(&:execute)
  end
  it "not runs if test fails" do
    ctx = Context.create!(fixture(:contexts,:failing).update(run_at: Time.now))
    Context.ready(1.second).map(&:execute)
  end
end