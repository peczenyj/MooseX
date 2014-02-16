require 'moosex'
require 'moosex/attribute/modifiers'

describe MooseX::AttributeModifiers::Is do
  it "should accept only valid parameters" do
    attribute = double()
    attribute.should_receive(:attr_symbol).and_return(:foo)
    expect { 
      MooseX::AttributeModifiers::Is.new(attribute).process({is: :forbidden})
    }.to raise_error(MooseX::InvalidAttributeError,
      "invalid value for field 'foo' is 'forbidden', must be one of :private, :rw, :rwp, :ro or :lazy")
  end
end

describe MooseX::AttributeModifiers::Predicate do
  it "should accept only valid parameters" do
    attribute = double()
    attribute.should_receive(:attr_symbol).and_return(:foo)
    expect { 
      MooseX::AttributeModifiers::Predicate.new(attribute).process({predicate: 0})
    }.to raise_error(MooseX::InvalidAttributeError,
      "cannot coerce field predicate to a symbol for foo: undefined method `to_sym' for 0:Fixnum")
  end
end

describe MooseX::AttributeModifiers::Handles do
  it "should accept only valid parameters" do
    attribute = double()
    attribute.should_receive(:attr_symbol).and_return(:foo)
    expect { 
      MooseX::AttributeModifiers::Handles.new(attribute).process({handles: BasicObject})
    }.to raise_error(MooseX::InvalidAttributeError,
      "ops, should not use BasicObject for handles in foo")
  end
end