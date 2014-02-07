require 'moosex'
require 'moosex/event'

class EventExample
  include MooseX
  include MooseX::Event
  
  def has_events
    [ :pinged, :ponged ]
  end
  
  def ping
    self.emit(:pinged)
  end
  
  def pong(message)
    self.emit(:ponged, message)
  end
  
end

class EventExample2 < EventExample
  def has_events; end
end

describe EventExample do
  it "EventExample should emit ping" do
    logger = double
    e = EventExample.new
    
    logger.should_receive(:on_pinged).with(e).once()
    e.on(:pinged) do |object|
      logger.on_pinged(object)
    end
    e.ping
  end
  
  it "EventExample should emit ping twice, on should receive twice but once will receive once" do
    logger1 = double
    logger2 = double
    
    e = EventExample.new
    
    logger1.should_receive(:on_pinged).with(e).twice()
    logger2.should_receive(:on_pinged).with(e).once()
    
    e.on(:pinged) do |object|
      logger1.on_pinged(object)
    end

    e.once(:pinged) do |object|
      logger2.on_pinged(object)
    end
        
    e.ping
    e.ping
  end  

  it "EventExample should emit ping twice, but you remove all listeners" do
    logger1 = double
    logger2 = double
    
    e = EventExample.new
    
    logger1.should_receive(:on_pinged).with(e).once()
    logger2.should_receive(:on_pinged).with(e).once()
    
    e.on(:pinged) do |object|
      logger1.on_pinged(object)
    end

    e.on(:pinged) do |object|
      logger2.on_pinged(object)
    end
        
    e.ping
    
    e.remove_all_listeners( :pinged )
    
    e.ping
  end
  
  it "EventExample should emit ping twice, but you remove one listener" do
    logger1 = double
    logger2 = double
    
    e = EventExample.new
    
    logger1.should_receive(:on_pinged).with(e).twice()
    logger2.should_receive(:on_pinged).with(e).once()
    
    e.on(:pinged) do |object|
      logger1.on_pinged(object)
    end

    listener = e.on(:pinged) do |object|
      logger2.on_pinged(object)
    end
        
    e.ping
    
    e.remove_listener( pinged: listener )
    
    e.ping
  end  

  it "should not add listener to a non supported event" do
    e = EventExample.new
    expect {  
      e.on(:xxx) {}
    }.to raise_error(MooseX::Event::EventException,
      "Event ':xxx' not supported, this class only allow: [:pinged, :ponged]")
  end
  
  it "should not add listener to a non supported event" do
    e = EventExample.new
    expect {  
      e.once(:xxx) {}
    }.to raise_error(MooseX::Event::EventException,
      "Event ':xxx' not supported, this class only allow: [:pinged, :ponged]")
  end
    
  it "should not emit a non supported event" do
    e = EventExample.new
    expect {  
      e.emit(:xxx)
    }.to raise_error(MooseX::Event::EventException,
      "Event ':xxx' not supported, this class only allow: [:pinged, :ponged]")
  end
  
  it "should emit ping and pong" do
    e = EventExample.new
    logger = double
    logger.should_receive(:receive_from_ping).with(e,1).once();
    
    e.once(:pinged) do |obj|
      obj.pong(1)  
    end  
    e.on(:ponged) do |obj, msg|
      logger.receive_from_ping(obj, msg)
    end
    
    e.ping
    e.ping
  end  
end

describe EventExample2 do
  it "should not add listener to a non supported event" do
    e = EventExample2.new
    e.once(:xxx) {}
  end
    
  it "should not emit a non supported event" do
    e = EventExample2.new

    logger = double
    logger.should_receive(:called_from_xxx).once()
    
    e.once(:xxx) { logger.called_from_xxx }

    e.emit(:xxx)
  end  
end
