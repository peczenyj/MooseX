require 'moosex/attribute/modifiers'

describe MooseX::Attribute::Is do
  it "should accept only valid parameters" do
    expect { 
      MooseX::Attribute::Is.new.process({is: :forbidden}, :foo)
    }.to raise_error(MooseX::InvalidAttributeError,
      "invalid value for field 'foo' is 'forbidden', must be one of :private, :rw, :rwp, :ro or :lazy")
  end
end

describe MooseX::Attribute::Predicate do
  it "should accept only valid parameters" do
    expect { 
      MooseX::Attribute::Predicate.new.process({predicate: 0}, :foo)
    }.to raise_error(MooseX::InvalidAttributeError,
      "cannot coerce field predicate to a symbol for foo: undefined method `to_sym' for 0:Fixnum")
  end
end

describe MooseX::Attribute::Handles do
  it "should accept only valid parameters" do
    expect { 
      MooseX::Attribute::Handles.new.process({handles: BasicObject}, :foo)
    }.to raise_error(MooseX::InvalidAttributeError,
      "ops, should not use BasicObject for handles in foo")
  end
end