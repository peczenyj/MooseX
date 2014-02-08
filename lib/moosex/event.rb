require 'moosex'
require 'moosex/types'

module MooseX
  module Event  
    class EventException < StandardError
    end  
    class EventListener
      include MooseX
      
      has once:  { is: :rw, reader: :once?  }
      has event: { is: :ro, handles: { :respond_to_event? => :== } }
      has code:  { is: :ro, handles: :call }

    end
    
    include MooseX
    include MooseX::Types
    
    has listeners: {
      is: :private,
      isa: isArray(EventListener),
      default: lambda{ [] },
    }

    def has_events
      nil
    end
    
    def on(event, &block)
      add_event_listener(event, false, block) 
    end

    def once(event, &block)
      add_event_listener(event, true, block)
    end
        
    def emit(event, *args)
      listeners.select{|l| l.respond_to_event?(event) }.each{|l| l.call(self, *args) }
      listeners.delete_if {|l| l.once? }
    end
    
    def remove_all_listeners(event)
      listeners.delete_if {|l| l.respond_to_event?(event) }
    end

    def remove_listener(data)
      data.each_pair do |event, listener|
        listeners.delete(listener)
      end  
    end
    
    private
    def add_event_listener(event, once, code)        
      listener = EventListener.new(event: event, once: once, code: code)
        
      listeners << listener
      
      listener
    end  

    before(:on, :once, :emit) do |obj, event, *rest, &proc|
      if ! obj.has_events.nil? && ! [ obj.has_events ].flatten.include?(event)
        
        raise EventException, "Event '#{event.inspect}' not supported, this class only allow: #{obj.has_events.inspect}",caller
        
      end    
    end
  end
end
