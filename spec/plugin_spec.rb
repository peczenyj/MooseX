require 'moosex'
require 'moosex/attribute'
require 'moosex/attribute/modifiers'

module MooseX
  module AttributeModifiers
    module ThirdParty
      class Bar
        def process(options, attr_symbol)
         !! options.delete(:bar)
        end
     end
    end
  end  
end

module MyPlugin
  def self.included(x)
    x.meta.add_plugin(:bar)
  end
end

module TestAddAttribute
  class A
    include MooseX.init(meta: true)
    include MyPlugin

    has :foo, {
      bar: true
    }
  end

  class B < A

    has :foo2, {
      bar: true
    }
  end

  class C
    include MooseX.init(meta: true)
    
    has :foo, {
      bar: true
    }
  end    
end

describe TestAddAttribute do
  it "A should support the new attribute" do
    TestAddAttribute::A.new(foo: 1)
  end

  it "A should support the new attribute in meta" do
    TestAddAttribute::A.meta.attrs[:foo].attribute_map[:bar].should be_true
  end 

  it "B should support the new attribute" do
    TestAddAttribute::B.new(foo: 1, foo2: 2)
  end

  it "B should support the new attribute in meta" do
    TestAddAttribute::B.meta.attrs[:foo].attribute_map[:bar].should be_true
    TestAddAttribute::B.meta.attrs[:foo2].attribute_map[:bar].should be_true   
  end    

  it "C should support the new attribute" do
    TestAddAttribute::C.new(foo: 1)
  end

  it "C should support the new attribute in meta" do
    TestAddAttribute::C.meta.attrs[:foo].attribute_map[:bar].should be_nil
  end       
end