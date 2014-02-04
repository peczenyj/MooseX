require 'moosex/types'

module Test
	include MooseX::Types
end

describe "MooseX::Types" do
	describe "Any" do
		it "should accept any value" do
			Test.isAny.call(nil)
			Test.isAny.call(1)
			Test.isAny.call(0)
			Test.isAny.call(true)
			Test.isAny.call(false)
			Test.isAny.call(:foo)
			Test.isAny.call("lol")
			Test.isAny.call([])
			Test.isAny.call({})
		end

		it "should return [Any]" do
			Test.isAny.to_s.should == "[Any]"
		end
	end

	describe "Constant" do
		it "should accept any value" do
			Test.isConstant(nil).call(nil)
			Test.isConstant(1).call(1)
			Test.isConstant(0).call(0)
			Test.isConstant(true).call(true)
			Test.isConstant(false).call(false)
			Test.isConstant(:foo).call(:foo)
			Test.isConstant("lol").call("lol")
			Test.isConstant([]).call([])
			Test.isConstant({}).call({})
		end

		it "should return [Constant: value (class)]" do
			Test.isConstant(nil).to_s.should == "[Constant: '' (NilClass)]"
			Test.isConstant(1).to_s.should == "[Constant: '1' (Fixnum)]"
			Test.isConstant(0).to_s.should == "[Constant: '0' (Fixnum)]"
			Test.isConstant(true).to_s.should == "[Constant: 'true' (TrueClass)]"
			Test.isConstant(false).to_s.should == "[Constant: 'false' (FalseClass)]"
			Test.isConstant(:foo).to_s.should == "[Constant: 'foo' (Symbol)]"
			Test.isConstant("lol").to_s.should == "[Constant: 'lol' (String)]"
			Test.isConstant([]).to_s.should == "[Constant: '[]' (Array)]"
			Test.isConstant({}).to_s.should == "[Constant: '{}' (Hash)]"
		end

		it "should raise error" do
			expect { 
				Test.isConstant(1).call(0) 
			}.to raise_error(MooseX::Types::TypeCheckError, "Constant violation: value '0' (Fixnum) is not '1' (Fixnum)")
		end
	end

	describe "Type" do

		it "should accept values" do
			Test.isType(NilClass).call(nil)
			Test.isType(Fixnum).call(1)
			Test.isType(Integer).call(1)
			Test.isType(Fixnum).call(0)
			Test.isType(Integer).call(0)			
			Test.isType(TrueClass).call(true)
			Test.isType(FalseClass).call(false)
			Test.isType(Symbol).call(:foo)
			Test.isType(String).call("lol")
			Test.isType(Array).call([])
			Test.isType(Hash).call({})			
		end

		it "should return [Type Class]" do
			Test.isType(NilClass).to_s.should == "[Type NilClass]"
			Test.isType(Fixnum).to_s.should == "[Type Fixnum]"
			Test.isType(Integer).to_s.should == "[Type Integer]"			
			Test.isType(TrueClass).to_s.should == "[Type TrueClass]"
			Test.isType(FalseClass).to_s.should == "[Type FalseClass]"
			Test.isType(Symbol).to_s.should == "[Type Symbol]"
			Test.isType(String).to_s.should == "[Type String]"
			Test.isType(Array).to_s.should == "[Type Array]"
			Test.isType(Hash).to_s.should == "[Type Hash]"
		end

		it "test aliases" do
			Test.isInstanceOf(TrueClass).call(true)
			Test.isConsumerOf(TrueClass).call(true)

			Test.isInstanceOf(TrueClass).to_s.should == "[Type TrueClass]"
			Test.isConsumerOf(TrueClass).to_s.should == "[Type TrueClass]"
		end

		it "Constant should raise error" do
			expect { 
				Test.isType(Array).call({}) 
			}.to raise_error(MooseX::Types::TypeCheckError, 
				"Type violation: value '{}' (Hash) is not an instance of [Type Array]")
		end

	end

	describe "AllOf" do

		it "should accept values" do
			Test.isAllOf(Object).call(nil)
			Test.isAllOf(Object, NilClass).call(nil)
			Test.isAllOf(Fixnum).call(1)
			Test.isAllOf(Fixnum,Integer).call(1)
			Test.isAllOf(Fixnum,Integer,Numeric).call(1)
			Test.isAllOf(Fixnum,Integer,Numeric, Test.isConstant(1)).call(1)

			Test.isAllOf(Test.isAllOf(Fixnum,Integer),Numeric, Test.isConstant(1)).call(1)	
		end	

		it "shouldreturn [AllOf *]" do
			Test.isAllOf(Object).to_s.should == "[AllOf [Object]]"
			Test.isAllOf(Object, NilClass).to_s.should == "[AllOf [Object, NilClass]]"
			Test.isAllOf(Fixnum).to_s.should == "[AllOf [Fixnum]]"
			Test.isAllOf(Fixnum,Integer).to_s.should == "[AllOf [Fixnum, Integer]]"
			Test.isAllOf(Fixnum,Integer,Numeric).to_s.should == "[AllOf [Fixnum, Integer, Numeric]]"
			Test.isAllOf(Fixnum,Integer,Numeric, Test.isConstant(1)).to_s
				.should == "[AllOf [Fixnum, Integer, Numeric, [Constant: '1' (Fixnum)]]]"

			Test.isAllOf(Test.isAllOf(Fixnum,Integer),Numeric, Test.isConstant(1)).to_s
				.should == "[AllOf [[AllOf [Fixnum, Integer]], Numeric, [Constant: '1' (Fixnum)]]]"
		end	

		it "Constant should raise error" do
			expect { 
				Test.isAllOf(Fixnum,Integer,Numeric, Test.isConstant(1)).call(2)
			}.to raise_error(MooseX::Types::TypeCheckError, 
				"AllOf Check violation: caused by [Constant violation: value '2' (Fixnum) is not '1' (Fixnum)]")

			expect { 
				Test.isAllOf(Fixnum,Integer,Numeric, Test.isConstant(1)).call(nil)
			}.to raise_error(MooseX::Types::TypeCheckError, 
				"AllOf Check violation: caused by [Type violation: value '' (NilClass) is not an instance of [Type Fixnum]]")

		end
	end

	describe "AnyOf" do

		it "should accept values" do
			Test.isAnyOf(Object).call(nil)
			Test.isAnyOf(Object, NilClass).call(nil)
			
			Test.isAnyOf(TrueClass, FalseClass).call(true)
			Test.isAnyOf(TrueClass, FalseClass).call(false)

			Test.isAnyOf(Fixnum).call(1)
			Test.isAnyOf(Fixnum,Integer).call(1)
			Test.isAnyOf(Fixnum,Integer,Numeric).call(1)
			Test.isAnyOf(Fixnum,Integer,Numeric, Test.isConstant(1)).call(1)
			
			Test.isAnyOf(Fixnum, String, Symbol).call(1)
			Test.isAnyOf(Fixnum, String, Symbol).call("string")
			Test.isAnyOf(Fixnum, String, Symbol).call(:symbol)

			Test.isAnyOf(Test.isConstant(0), Test.isConstant(1)).call(1)
			Test.isAnyOf(Test.isConstant(0), Test.isConstant(1)).call(0)

			Test.isAnyOf(Test.isAllOf(Fixnum,Integer),Numeric, Test.isConstant(1)).call(1)
			Test.isAnyOf(Test.isAllOf(Fixnum,Integer),Numeric, Test.isConstant(1)).call(2)
			Test.isAnyOf(Test.isAllOf(Fixnum,Integer),Numeric, Test.isConstant(1)).call(3.0)		
		end	

		it "should return [AnyOf *]" do
			Test.isAnyOf(Object).to_s.should == "[AnyOf [Object]]"
			Test.isAnyOf(Object, NilClass).to_s.should == "[AnyOf [Object, NilClass]]"
			Test.isAnyOf(Fixnum).to_s.should == "[AnyOf [Fixnum]]"
			Test.isAnyOf(Fixnum,Integer).to_s.should == "[AnyOf [Fixnum, Integer]]"
			Test.isAnyOf(Fixnum,Integer,Numeric).to_s.should == "[AnyOf [Fixnum, Integer, Numeric]]"
			Test.isAnyOf(Fixnum,Integer,Numeric, Test.isConstant(1)).to_s
				.should == "[AnyOf [Fixnum, Integer, Numeric, [Constant: '1' (Fixnum)]]]"

			Test.isAnyOf(Test.isAllOf(Fixnum,Integer),Numeric, Test.isConstant(1)).to_s
				.should == "[AnyOf [[AllOf [Fixnum, Integer]], Numeric, [Constant: '1' (Fixnum)]]]"
		end	

		it "should raise error" do
			expect { 
				Test.isAnyOf(TrueClass, FalseClass).call(nil)
			}.to raise_error(MooseX::Types::TypeCheckError, 
				"AnyOf Check violation: caused by [Type violation: value '' (NilClass) is not an instance of [Type TrueClass], Type violation: value '' (NilClass) is not an instance of [Type FalseClass]]")

			expect { 
				Test.isAnyOf(Fixnum, String, Symbol).call([])
			}.to raise_error(MooseX::Types::TypeCheckError, 
				"AnyOf Check violation: caused by [Type violation: value '[]' (Array) is not an instance of [Type Fixnum], Type violation: value '[]' (Array) is not an instance of [Type String], Type violation: value '[]' (Array) is not an instance of [Type Symbol]]")

		end
	end

	describe "Enum" do
		it "should accept a constant value" do
			Test.isEnum(1,2,3).call(1)
			Test.isEnum(1,2,3).call(2)
			Test.isEnum(1,2,3).call(3)
		end

		it "should return [Enum ...]" do
			Test.isEnum(1,2,3).to_s.should == "[Enum [1, 2, 3]]"
		end
		
		it "should raise error"	do
			expect { 
				Test.isEnum(1,2,3).call(4)
			}.to raise_error(MooseX::Types::TypeCheckError, 
				"Enum Check violation: value '4' (Fixnum) is not [1, 2, 3]")
		end
	end

	describe "Not" do
		it "should accept values" do
			Test.isNot(Test.isConstant(1)).call(0)
			Test.isNot(Test.isType(String)).call(0)
			Test.isNot(Test.isAnyOf(TrueClass, FalseClass)).call(nil)
			
			Test.isNot(Test.isType(Array)).call({}) 
			Test.isNot(Test.isEnum(1,2,3)).call(4)

			Test.isNot(Test.isAnyOf(Fixnum, String, Symbol)).call([])
			Test.isNot(Test.isAnyOf(TrueClass, FalseClass)).call(3)

			Test.isNot(Test.isAllOf(Fixnum,Integer,Numeric, Test.isConstant(1))).call(2)
			Test.isNot(Test.isAllOf(Fixnum,Integer,Numeric, Test.isConstant(1))).call(nil)			
		end

		it "shuld return [NOT ...]" do
			Test.isNot(Test.isConstant(1)).to_s.should == "[NOT [Constant: '1' (Fixnum)]]"
			Test.isNot(Test.isType(String)).to_s.should == "[NOT [Type String]]"
			Test.isNot(Test.isAnyOf(TrueClass, FalseClass)).to_s
				.should == "[NOT [AnyOf [TrueClass, FalseClass]]]"
			
			Test.isNot(Test.isType(Array)).to_s.should == "[NOT [Type Array]]"
			Test.isNot(Test.isEnum(1,2,3)).to_s.should == "[NOT [Enum [1, 2, 3]]]"

			Test.isNot(Test.isAnyOf(Fixnum, String, Symbol)).to_s
				.should == "[NOT [AnyOf [Fixnum, String, Symbol]]]"


			Test.isNot(Test.isAllOf(Fixnum,Integer,Numeric, Test.isConstant(1))).to_s
				.should == "[NOT [AllOf [Fixnum, Integer, Numeric, [Constant: '1' (Fixnum)]]]]"
		end

		it "should raise error" do
			expect { 
				Test.isNot(Test.isEnum(1,2,3)).call(2)
			}.to raise_error(MooseX::Types::TypeCheckError, 
				"Not violation: value '2' (Fixnum) is not [Enum [1, 2, 3]]")
		end
	end

	describe "Maybe" do
		it "should accept value or nil" do
			Test.isMaybe(Test.isConstant(9)).call(9)
			Test.isMaybe(Test.isType(TrueClass)).call(true)
			Test.isMaybe(Test.isEnum(1,2,3)).call(1)

			Test.isMaybe(Test.isConstant(9)).call(nil)
			Test.isMaybe(Test.isType(TrueClass)).call(nil)
			Test.isMaybe(Test.isEnum(1,2,3)).call(nil)		

			Test.isMaybe(TrueClass).call(nil)
			Test.isMaybe(TrueClass).call(true)

			Test.isMaybe(Test.isAllOf(Fixnum,Integer,Numeric, Test.isConstant(1))).call(nil)	
		end

		it "should return [Maybe [...]]" do
			Test.isMaybe(Test.isConstant(9)).to_s.should == "[Maybe [Constant: '9' (Fixnum)]]"
			Test.isMaybe(Test.isType(TrueClass)).to_s.should == "[Maybe [Type TrueClass]]"
			Test.isMaybe(TrueClass).to_s.should == "[Maybe TrueClass]"
			Test.isMaybe(Test.isEnum(1,2,3)).to_s.should == "[Maybe [Enum [1, 2, 3]]]"
			Test.isMaybe(Test.isAllOf(Fixnum,Integer,Numeric, Test.isConstant(1))).to_s
				.should == "[Maybe [AllOf [Fixnum, Integer, Numeric, [Constant: '1' (Fixnum)]]]]"
		end

		it "should raise error" do
			expect {
				Test.isMaybe(Test.isConstant(9)).call(8)
			}.to raise_error(MooseX::Types::TypeCheckError, 
				"Maybe violation: caused by AnyOf Check violation: caused by [Constant violation: value '8' (Fixnum) is not '9' (Fixnum), Constant violation: value '8' (Fixnum) is not '' (NilClass)]")

			expect {
				Test.isMaybe(TrueClass).call(false)
			}.to raise_error(MooseX::Types::TypeCheckError, 
				"Maybe violation: caused by AnyOf Check violation: caused by [Type violation: value 'false' (FalseClass) is not an instance of [Type TrueClass], Constant violation: value 'false' (FalseClass) is not '' (NilClass)]")

		end
	end

	describe "Array" do
		it "should accept values" do
			Test.isArray().call([])
			Test.isArray().call([1])
			Test.isArray().call([1,2])

			Test.isArray(Integer).call([])
			Test.isArray(Integer).call([1])
			Test.isArray(Integer).call([1,2])
			
			Test.isArray(Test.isMaybe(Integer)).call([1,2,nil])
			Test.isArray(Test.isArray(Integer)).call([[1,2],[3,4]])
		end

		it "should return [Array ]" do
			Test.isArray().to_s.should == "[Array [Any]]"
			Test.isArray(Integer).to_s.should == "[Array Integer]"
			Test.isArray(Test.isMaybe(Integer)).to_s.should == "[Array [Maybe Integer]]"
			Test.isArray(Test.isArray(Integer)).to_s.should == "[Array [Array Integer]]"			
		end

		it "should raise error" do
			expect {
				Test.isArray(Test.isArray(Test.isMaybe(Integer))).call(nil)
			}.to raise_error(MooseX::Types::TypeCheckError, 
				"Type violation: value '' (NilClass) is not an instance of [Type Array]")

			expect {
				Test.isArray(Test.isArray(Test.isMaybe(Integer))).call([false])
			}.to raise_error(MooseX::Types::TypeCheckError, 
				"Array violation: caused by Type violation: value 'false' (FalseClass) is not an instance of [Type Array]")

			expect {
				Test.isArray(Test.isArray(Test.isMaybe(Integer))).call([[false]])
			}.to raise_error(MooseX::Types::TypeCheckError, 
				"Array violation: caused by Array violation: caused by Maybe violation: caused by AnyOf Check violation: caused by [Type violation: value 'false' (FalseClass) is not an instance of [Type Integer], Constant violation: value 'false' (FalseClass) is not '' (NilClass)]")			
		end
	end

	describe "Hash" do
		it "should accept values" do
			Test.isHash().call({})
			Test.isHash().call({ a: 1 })
			Test.isHash().call({ 1 => 2})

			Test.isHash(Integer => Integer).call({})
			Test.isHash(Integer => Integer).call({1 => 2})
			Test.isHash(Integer => Integer).call({2 => 1, 4 => 5})

			Test.isHash(Symbol => Test.isArray(Test.isMaybe(Test.isEnum(1,2,3))))
				.call( foo: [nil, 1,2,3], bar: [nil, 2], baz: [])
		end

		it "should return [Hash ]" do
			Test.isHash()
				.to_s.should == "[Hash [Any] => [Any]]"

			Test.isHash(Integer => Integer)
				.to_s.should == "[Hash Integer => Integer]"

			Test.isHash(Symbol => Test.isArray(Test.isMaybe(Test.isEnum(1,2,3))))
				.to_s.should == "[Hash Symbol => [Array [Maybe [Enum [1, 2, 3]]]]]"
		end

		it "should raise error" do
			expect{
				Test.isHash().call(nil)
			}.to raise_error(MooseX::Types::TypeCheckError,
				"Type violation: value '' (NilClass) is not an instance of [Type Hash]")
			expect{
				Test.isHash(Symbol => Integer).call({ 1 => 2})
			}.to raise_error(MooseX::Types::TypeCheckError,
				"Hash violation: caused by Type violation: value '1' (Fixnum) is not an instance of [Type Symbol]")			
		end
	end

	describe "Tuple" do
		it "should accept values" do
			Test.isTuple().call([])

			Test.isTuple(Test.isAny).call([1])
			Test.isTuple(Test.isAny, Test.isAny).call([1,2])

			Test.isTuple(Integer).call([1])
			Test.isTuple(Integer, Integer).call([1,2])
			
			Test.isTuple(Integer, Symbol, Test.isAny, TrueClass).call([1,:symbol, nil, true])
		end

		it "should return [Tuple ]" do
			Test.isTuple().to_s.should == "[Tuple []]"
			Test.isTuple(Integer).to_s.should == "[Tuple [Integer]]"
			Test.isTuple(Integer, Integer).to_s.should == "[Tuple [Integer, Integer]]"
			Test.isTuple(Integer, Symbol, Test.isAny, TrueClass).to_s
				.should == "[Tuple [Integer, Symbol, [Any], TrueClass]]"
		end

		it "should raise error" do
			expect {
				Test.isTuple().call([1])
			}.to raise_error(MooseX::Types::TypeCheckError,
				"Tuple violation: size should be 0 instead 1")
			expect {
				Test.isTuple(Integer).call([])
			}.to raise_error(MooseX::Types::TypeCheckError,
				"Tuple violation: size should be 1 instead 0")
			expect {
				Test.isTuple().call(nil)
			}.to raise_error(MooseX::Types::TypeCheckError,
				"Type violation: value '' (NilClass) is not an instance of [Type Array]")							
			expect {
				Test.isTuple(Integer, Symbol, Test.isAny, TrueClass).call([1,:symbol, nil, false])
			}.to raise_error(MooseX::Types::TypeCheckError,
				"Tuple violation: on position 3 caused by Type violation: value 'false' (FalseClass) is not an instance of [Type TrueClass]")					
		end
	end

	describe "Set" do
		it "should accept values" do
			Test.isSet().call([])
			Test.isSet().call([1])
			Test.isSet().call([1,2])

			Test.isSet(Integer).call([])
			Test.isSet(Integer).call([1])
			Test.isSet(Integer).call([1,2])
		end

		it "should return [Set ]" do
			Test.isSet().to_s.should == "[Set [Any]]"
			Test.isSet(Integer).to_s.should == "[Set Integer]"
			Test.isSet(Test.isMaybe(Integer)).to_s.should == "[Set [Maybe Integer]]"
			Test.isSet(Test.isArray(Integer)).to_s.should == "[Set [Array Integer]]"			
		end

		it "should raise error" do
			expect {
				Test.isSet(Test.isArray(Test.isMaybe(Integer))).call(nil)
			}.to raise_error(MooseX::Types::TypeCheckError, 
				"Type violation: value '' (NilClass) is not an instance of [Type Array]")

			expect {
				Test.isSet(Test.isArray(Test.isMaybe(Integer))).call([false])
			}.to raise_error(MooseX::Types::TypeCheckError, 
				"Set violation: caused by Type violation: value 'false' (FalseClass) is not an instance of [Type Array]")

			expect {
				Test.isSet(Test.isArray(Test.isMaybe(Integer))).call([[false]])
			}.to raise_error(MooseX::Types::TypeCheckError, 
				"Set violation: caused by Array violation: caused by Maybe violation: caused by AnyOf Check violation: caused by [Type violation: value 'false' (FalseClass) is not an instance of [Type Integer], Constant violation: value 'false' (FalseClass) is not '' (NilClass)]")

			expect {
				Test.isSet(Integer).call([1,2,2])
			}.to raise_error(MooseX::Types::TypeCheckError, 
				"Set violation: has one or more non unique elements: {2=>2} (value => count)")
		end
	end

	describe "hasMethods" do
		class MyFoo
			def bar ; end
			def baz ; end
		end

		it "should verify if has methods" do
			Test.hasMethods(:bar).call(MyFoo.new)
			Test.hasMethods(:baz).call(MyFoo.new)
			Test.hasMethods(:bar, :baz).call(MyFoo.new)
		end

		it "should return [hasMethods ...]" do
			Test.hasMethods(:bar).to_s.should == "[hasMethods [:bar]]"
			Test.hasMethods(:bar, :baz).to_s.should == "[hasMethods [:bar, :baz]]"
		end

		it "should raise error" do
			expect {
				Test.hasMethods(:bar, :baz, :bam).call(1)
			}.to raise_error(MooseX::Types::TypeCheckError,
				"hasMethods violation: object 1 (Fixnum) should implement method bar")
		end
	end
end