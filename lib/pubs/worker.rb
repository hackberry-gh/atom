require './config/env'
require 'config/application'
require 'eventmachine'
require "em-synchrony"

module Pubs
  class Worker
  
    def work
      Proc.new {

        Fiber.new {

          Fiber.yield nil unless sequence = Sequence.get

          ids = sequence.event_ids

          ids.each_slice(ids.count / ids.size) do |_ids|

            # Working not bad
            # 1000 item ~4 mins but loks faster
            Fiber.new {
              sequence.events(_ids).try(:each){ |event|
                Fiber.new {
                  # event.trigger
                  event.notify
                }.resume
              }
            }.resume

          end

        }.resume

      }
    end


    def initialize

      EM.synchrony {
        EM.add_periodic_timer(Sequence::MINUTE,work)
        work.call
      }

    end

  end
end