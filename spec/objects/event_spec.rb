describe :event do

  it "runs arbitary code with set of rules" do
    Element.create!(fixture(:elements,:user))
    Element.create!(fixture(:elements,:counter))
    source = User.create!(fixture(:events,:signup_source))
    target = Counter.create!(fixture(:events,:signup_target))
    ctx = Context.create!(fixture(:events,:signup_context))
    prg = Program.create!(fixture(:events,:signup_program))
    evt = Event.create!(source_id: source.id, target_id: target.id,
    context_id: ctx.id, program_id: prg.id)
    evt.trigger
    evt.status.must_equal Event::DONE
  end

end