require 'moosex'

class SuperTypes
	include MooseX
	include MooseX::Types

	has x: {
		is: :rw,
		isa: isAnyOf(
			isConstant(1), 
			isMaybe(Integer),
			isArray( hasMethods(:baz) ),
			isEnum(:foo, :bar)
		)
	}
end

describe "SuperTypes" do
	it "should verify tyoe if x" do
		SuperTypes.new(x: 1)
		SuperTypes.new(x: nil)
		SuperTypes.new(x: 1024)
		SuperTypes.new(x: [])
		SuperTypes.new(x: :foo)						
	end

	it "should raise error" do
		expect {
			SuperTypes.new(x: [1])
		}.to raise_error(MooseX::Types::TypeCheckError,
			"isa check for field x: AnyOf Check violation: caused by [Constant violation: value '[1]' (Array) is not '1' (Fixnum), Maybe violation: caused by AnyOf Check violation: caused by [Type violation: value '[1]' (Array) is not an instance of [Type Integer], Constant violation: value '[1]' (Array) is not '' (NilClass)], Array violation: caused by hasMethods violation: object 1 (Fixnum) should implement method baz, Enum Check violation: value '[1]' (Array) is not [:foo, :bar]]")
	end
end