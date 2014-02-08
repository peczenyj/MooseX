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
=begin
require 'moosex/types'

class CoerceTest2
  include MooseX
  include MooseX::Types

  has a: { is: :rw, coerce: :to_i }                   # if respond_to? then coerce
  has b: { is: :rw, coerce: { to_i: true } }          # always coerce
  has c: { is: :rw, coerce: { to_i: false} }          # if respond_to? then coerce 
  has d: { is: :rw, coerce: [ :to_s, :to_string ] }   # try to apply one of
  has e: { is: :rw, coerce: [                         # if respond_to? then coerce via method/lambda
    {  to_s: lambda{|x| x.to_s.to_sym } },            # can add more, will be evaluated in order
    {  to_sym: :to_sym  },
   ] 
  }
  has f: { is: :rw, coerce: [                         # should accept one array of 
       { String => lambda{|x| x.to_sym } },           # type => coerce
       { Object => lambda{|x| x.to_s } },
    ]
  }
  has g: { is: :rw, coerce: { String => :to_sym } }   # should accept one pair
  has h: { is: :rw, coerce: {                         # should accept one type validator
    isArray(String) => lambda{|obj| obj.join(",") } 
    }
  }  
  has i: {is: :rw, isa: isString(format: /\w+:\w+/) } # validator with autocoerce!

end

describe CoerceTest2 do

end
=end
