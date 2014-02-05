require 'moosex'

module ComplexRole
	module Eq
		include MooseX.disable_warnings()

		requires :equal

		def no_equal(other)
			! self.equal(other)
		end
	end

	module Valuable
		include MooseX

		has value: { is: :ro, requires: true } 
	end	

	class Currency
		include Valuable
		include Eq  # will warn unless disable_warnings was called.
                    # to avoid warnings, you should include after  
		            # define all required modules,

		def equal(other)
			self.value == other.value
		end

		# include Eq            # warning safe include
	end
	
	class Comparator
		include MooseX

		has compare_to: { 
			is: :ro,
			isa: Eq,
			handles: Eq, 
		}
	end

	module Wrapper
		include Eq
	end

	class WrongClass
		include Wrapper

		has one: { is: :rw }
	end
end

describe "ComplexRole::Currency" do
	it "should compare based on value" do
		c1 = ComplexRole::Currency.new( value: 12 )
		c2 = ComplexRole::Currency.new( value: 12 )
		c3 = ComplexRole::Currency.new( value: 24 )

		c1.equal(c2).should be_true
		c1.equal(c3).should be_false
	end
end	

describe ComplexRole::Comparator do
	it "should compare two Currency instances" do
		c1 = ComplexRole::Currency.new( value: 12 )
		c2 = ComplexRole::Currency.new( value: 12 )
		c3 = ComplexRole::Currency.new( value: 24 )

		ComplexRole::Comparator.new(compare_to: c1).no_equal(c2).should be_false
		ComplexRole::Comparator.new(compare_to: c1).no_equal(c3).should be_true	
	end
end

describe ComplexRole::WrongClass do
	it "should die unless implement missing method" do
		expect {		
			ComplexRole::WrongClass.new(one: 1, two: 2)
		}.to raise_error(MooseX::RequiredMethodNotFoundError,
			"you must implement method 'equal' in ComplexRole::WrongClass: required")
	end
end
