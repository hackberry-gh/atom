describe :program do
  it "runs arbitary code" do
    program = Program.create!(fixture(:programs,:puts))
    program.execute
    program.result.must_equal "Hello World"
  end
end