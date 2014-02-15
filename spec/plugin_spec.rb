require 'moosex'
require 'moosex/attribute'
require 'moosex/attribute/modifiers'

module MooseX
  module AttributeModifiers
    module ThirdParty
      class Chained
        def initialize(this)
          @this = this
        end
        def process(options)
         
         chained = !! options.delete(:chained)
         
         if chained
           writter  = @this.attribute_map[:writter]
           old_proc = @this.methods[ writter ]
           @this.methods[writter] = ->(this, value) { old_proc.call(this, value); this }   
         end
         
         chained
        end
     end
    end
  end  
end

module MyPlugin
  def self.included(x)
    x.__moosex__meta.add_plugin(:chained)
  end
end

module TestAddAttribute
  class A
    include MooseX.init(meta: true)
    include MyPlugin

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
      chained: true
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