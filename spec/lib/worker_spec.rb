require 'pubs/worker'

describe :worker do
  
  it "fetches notifications every second and run them" do

    Element.create!(fixture(:elements,:user))
    Element.create!(fixture(:elements,:counter))
    
    source = User.create!(fixture(:events,:signup_source))
    target = Counter.create!(fixture(:events,:signup_target))
    
    prg = Program.create!(fixture(:events,:signup_program))


    generate = Proc.new{
      (1..10).each do |i|
        
        ctx = Fiber.new { 
          Fiber.yield Context.create!(fixture(:events,:signup_context).
          update(run_at: rand < 0.5 ? "Time.now+#{(rand*100).to_i}.seconds" : "Time.now"))            
        }
        event = Fiber.new{ |ctx|
          Event.create!(source_id: source.id, target_id: target.id, context_id: ctx.id, program_id: prg.id)
        }
        event.resume ctx.resume 
        

        
      end
    }
    
    # (1..10).each { generate.call }
    
    puts "START #{Time.now}"
    
    ap Sequence.count
    ap Event.count
    
    # worker = Pubs::Worker.new


  end
end