describe :sequence do
  
  
  it "holds events by run time" do
    

    Element.create!(fixture(:elements,:user))
    Element.create!(fixture(:elements,:counter))
    source = User.create!(fixture(:events,:signup_source))
    target = Counter.create!(fixture(:events,:signup_target))
    ctx = Context.create!(fixture(:events,:signup_context))
    prg = Program.create!(fixture(:events,:signup_program))
    evt = Event.create!(source_id: source.id, target_id: target.id,
    context_id: ctx.id, program_id: prg.id)

    Sequence.get.must_equal nil
    Sequence.get(Time.now+1.minute).try(:events).try(:count).must_equal 1
    Sequence.get(Time.now+2.minute).must_equal nil 
    
  end
  
  
end