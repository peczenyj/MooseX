require 'moosex'
require 'moosex/traits'
require 'moosex/plugins'

module TestAddAttribute  
  class EmailMessage
    include MooseX.init(
        with_plugins: MooseX::Plugins::Chained
      )
    has :_from, writter: :from, chained: true
    has :_to, writter: :to, chained: true
    has :_subject, writter: :withSubject, chained: true
    has :_body , writter: :withBody, chained: true
    
    def send 
      { 
        from: self._from, 
        to:   self._to,
        subject: self._subject,
        body: self._body,
      }
    end      
  end
  
  class A
    include MooseX.init(
        meta: true, 
        with_plugins: MooseX::Plugins::Chained
      )

    has :foo, {
      writter: :set_foo,
      chained: true
    }
  end

  class B < A

    has :foo2, {
      writter: :set_foo2,
      chained: true
    }

    has :foo3, {
      writter: :set_foo3,
      chained: false
    }    
  end

  class C
    include MooseX.init(meta: true)
    
    has :foo, {
      writter: :set_foo,
      chained: true, # will warn only!
    }
  end    
end

describe TestAddAttribute do
  it "A should support the new attribute" do
    TestAddAttribute::A.new(foo: 1)
  end

  it "A should support the new attribute in meta" do
    TestAddAttribute::A.meta.attrs[:foo].attribute_map[:chained].should be_true
  end 

  it "A should return self in writter" do
    a = TestAddAttribute::A.new(foo: 1)
    a.foo.should == 1
    a.set_foo(2).should == a
    a.foo.should == 2
  end

  it "B should support the new attribute" do
    TestAddAttribute::B.new(foo: 1, foo2: 2)
  end

  it "B should support the new attribute in meta" do
    TestAddAttribute::B.meta.attrs[:foo].attribute_map[:chained].should be_true
    TestAddAttribute::B.meta.attrs[:foo2].attribute_map[:chained].should be_true   
  end    

  it "B should return self in writter" do
    a = TestAddAttribute::B.new(foo: 1, foo2: 2)
    a.foo.should == 1
    a.foo2.should == 2
    a.set_foo(2).should == a
    a.set_foo2(4).should == a
    a.foo.should == 2
    a.foo2.should == 4
    
    a.set_foo(5).set_foo2(9).should == a
    a.foo.should == 5
    a.foo2.should == 9
  end

  it "B foo3 should not be chained" do
    a = TestAddAttribute::B.new(foo3: 4)
    a.foo3.should == 4
    a.set_foo3(7).should == 7
    a.foo3.should == 7 
  end

  it "C should support the new attribute" do
    TestAddAttribute::C.new(foo: 1)
  end

  it "C should support the new attribute in meta" do
    TestAddAttribute::C.meta.attrs[:foo].attribute_map[:chained].should be_nil
  end
  
  it "C should return value in writter" do
    a = TestAddAttribute::C.new(foo: 1)
    a.foo.should == 1
    a.set_foo(2).should == 2
    a.foo.should == 2
  end         
end

describe "TestAddAttribute::EmailMessage" do

  it "should return a hash with options" do
    TestAddAttribute::EmailMessage.new.
      from("foo@bar.com").
      to("me@baz.com").
      withSubject("test").
      withBody("hi!").
      send.should == {
        from: "foo@bar.com",
        to: "me@baz.com",
        subject: "test",
        body: "hi!"
      }
  end
end

module TestAddAttribute 
  class MyClass
    include MooseX.init(meta: true, with_plugins: MooseX::Plugins::ExpiredAttribute)
    
    has :log
    
    has config: {
      is: :lazy,
      expires: 4,      # seconds
    }
    
    has :session, default: ->{ {} }, expires: -1
    
    def build_config
      log.info(:created)
      { foo: 1 }
    end
  end
end

describe TestAddAttribute::MyClass do
  it "should reload config, but not session" do
    log = double
    log.should_receive(:info).with(:created).twice
    
    c = TestAddAttribute::MyClass.new(log: log)

    c.config.should == { foo: 1}
    c.session.valid?.should be_true
    
    sleep(4)
    
    c.config.should == { foo: 1}
    c.session.valid?.should be_true
  end
end  
