require 'moosex'

class CoerceTest
	include MooseX

	has attribute_ro: {
		is: :ro,
		isa: Integer,
		coerce: lambda {|value| value.to_i },
	}

	has attribute_rw: {
		is: :rw,
		isa: Integer,
		coerce: :to_i,
	}

	has attribute_lazy: {
		is: :lazy,
		isa: Integer,
		coerce: lambda {|value| value.to_i },
		builder: lambda{|object| "2048" },
	}
end

describe "CoerceTest" do
	it "should coerce the argument using to_i on constructor" do
		ct = CoerceTest.new(attribute_ro: "12")
		ct.attribute_ro.should == 12
	end

	it "should coerce the argument using to_i on constructor" do
		ct = CoerceTest.new(attribute_rw: "12")
		ct.attribute_rw.should == 12
	end

	it "should coerce in the setter" do
		ct = CoerceTest.new
		ct.attribute_rw= "128"
		ct.attribute_rw.should == 128
	end

	it "should coerce from builder" do
		ct = CoerceTest.new
		ct.attribute_lazy.should == 2048
	end
end
