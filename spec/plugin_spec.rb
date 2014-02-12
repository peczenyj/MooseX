require 'moosex'
require 'moosex/attribute'
require 'moosex/attribute/modifiers'

module MyPlugin
  def self.included(k)
    MooseX::Attribute.register_new_parameter(:bar, MyPlugin::Y::Bar.new)
  end

  module Y
    class Bar
      def process(options, attr_symbol)
        !! options.delete(:bar)
      end
    end
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
end

describe TestAddAttribute do
  it "should support the new attribute" do
    TestAddAttribute::A.new(foo: 1)
  end

  it "should support the new attribute in meta" do
    TestAddAttribute::A.meta.attrs[:foo].attribute_map[:bar].should be_true
  end  
end