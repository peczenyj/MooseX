require 'moosex/attribute/modifiers'

describe MooseX::AttributeModifiers::Is do
  it "should accept only valid parameters" do
    expect { 
      MooseX::AttributeModifiers::Is.new.process({is: :forbidden}, :foo)
    }.to raise_error(MooseX::InvalidAttributeError,
      "invalid value for field 'foo' is 'forbidden', must be one of :private, :rw, :rwp, :ro or :lazy")
  end
end

describe MooseX::AttributeModifiers::Predicate do
  it "should accept only valid parameters" do
    expect { 
      MooseX::AttributeModifiers::Predicate.new.process({predicate: 0}, :foo)
    }.to raise_error(MooseX::InvalidAttributeError,
      "cannot coerce field predicate to a symbol for foo: undefined method `to_sym' for 0:Fixnum")
  end
end

describe MooseX::AttributeModifiers::Handles do
  it "should accept only valid parameters" do
    expect { 
      MooseX::AttributeModifiers::Handles.new.process({handles: BasicObject}, :foo)
    }.to raise_error(MooseX::InvalidAttributeError,
      "ops, should not use BasicObject for handles in foo")
  end
end