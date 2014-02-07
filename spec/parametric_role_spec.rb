require 'moosex'
require 'logger'

module Logabble
  include MooseX
  
  has logger: {
    is: :ro,
    #isa: Logger,
    default: lambda{ 
      logger = Logger.new(STDOUT) 
      logger.level = Logger::INFO
      logger
    },
    handles: {
      log_info: :info, 
      log_warn: :warn, 
      log_fatal: :fatal, 
      log_debug: :debug 
    }
  }
  
  on_init do | args |

    klass  = args[:klass]    || self  # this is necessary if you need composable Roles
    methods = args[:methods] || []    

    methods.each do |method|
      klass.around(method) do |original, object, *args|
      
        object.log_info([args])
        
        begin
        result = original.call(object, *args)
        
        object.log_warn(result)
        
        result
        rescue => e
          object.log_fatal(e.message)
          nil
        end 
      end
      
    end
    
  end
  
end

module Logabble2
  include MooseX
  
  has y: { is: :rw }
  
  on_init do |args|
    args[:klass] = self
    include Logabble.init(args)
  end  
end


module EasyCrud
  include MooseX
  
  on_init do |*attributes|
    attributes.each do | attr |
      has attr, { is: :rw, predicate: "has_attr_#{attr}_or_not?" }
    end
  end
end

class LogTest
  include EasyCrud.init(:a, :b)
  
  def foo; 1 ; end
  def bar(a); 1 / a ; end
  def baz(a,b); 1 + a + b; end
  
  include Logabble.init(methods: [:foo, :bar, :baz])
end

class LogTest2
  include MooseX
  
  def foo; 1 ; end
  def bar(a); 1 / a ; end
  def baz(a,b); 1 + a + b; end
  
  include Logabble2.init(methods: [:foo, :bar, :baz, :y=])
end

describe LogTest do
  it "should has a logger" do
    l = LogTest.new()
    l.logger.is_a?(Logger).should be_true
  end

  it "should has :a and :b attr" do
    l = LogTest.new()
    
    l.has_attr_a_or_not?.should be_false
    l.has_attr_b_or_not?.should be_false
  end
    
  it "should has :a and :b attrs defined" do
    l = LogTest.new(a: 1, b: 2)
    
    l.has_attr_a_or_not?.should be_true
    l.has_attr_b_or_not?.should be_true
    
    l.a.should == 1
    l.b.should == 2
    
    l.a = 5
    l.b = 6
    
    l.a.should == 5
    l.b.should == 6    
  end
   
  it "call bar(0) should call logger info and fatal" do
    logger = double
    logger.should_receive(:info).with([[0]])
    logger.should_receive(:fatal).with("divided by 0")
    
    l = LogTest.new(logger: logger)
    l.bar(0)
  end
  
  it "call bar(1) should call logger info and warn" do
    logger = double
    logger.should_receive(:info).with([[2]])
    logger.should_receive(:warn).with(1/2)
    
    l = LogTest.new(logger: logger)
    l.bar(2)
  end  
end

describe LogTest2 do
  it "should has a logger" do
    l = LogTest2.new()
    l.logger.is_a?(Logger).should be_true
  end
  
  it "call bar(0) should call logger info and fatal" do
    logger = double
    logger.should_receive(:info).with([[0]])
    logger.should_receive(:fatal).with("divided by 0")
    
    l = LogTest2.new(logger: logger)
    l.bar(0)
  end
  
  it "call bar(1) should call logger info and warn" do
    logger = double
    logger.should_receive(:info).with([[2]])
    logger.should_receive(:warn).with(1/2)
    
    l = LogTest2.new(logger: logger)
    l.bar(2)
  end  
  
  it "call y= should call logger" do
    log = double
    log.should_receive(:info).with([[123]])
    log.should_receive(:warn).with(123)
    
    l = LogTest2.new(logger: log)
    l.y = 123
  end
  
end
