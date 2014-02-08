#
# This example was ported from
# http://search.cpan.org/~winter/MooseX-Event-v0.2.0/lib/MooseX/Event.pm

require 'moosex'
require 'moosex/event'

class EventHandler
  include MooseX
  include MooseX::Event
  
  def has_events
    [ :pinged, :ponged ]
  end    
end

class EventProcessor
  include MooseX
  
  has event_handler: {
    is: :ro,
    isa: EventHandler,
    default: lambda{ EventHandler.new },
    handles: {
      ping: { emit: :pinged },
      pong: { emit: :ponged },
      on_ping: { on: :pinged },
      on_pong: { on: :ponged },
    },
  }
end

ep = EventProcessor.new()

ep.on_ping do |x| 
  puts "receive ping!"
end

ep.on_pong do |obj, message| 
  puts "receive pong with #{message}!"
end  

ep.ping   # will print "receive ping!"
ep.pong 1 # will print "receive pong!"
