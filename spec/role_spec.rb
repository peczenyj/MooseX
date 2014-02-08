require 'moosex'

module ComplexRole
	module Eq
		include MooseX #.disable_warnings()

		requires :equal

		def no_equal(other)
			! self.equal(other)
		end
	end

	module Valuable
		include MooseX

		has value: { is: :ro, required: true } 
	end	

	class Currency
	  include MooseX
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

module AfterBefore
	module Sayhi
		include MooseX
		requires :say
		before(:say) do |object, message|
			object.logger.before_say_2(message)
		end
	end

	module Sayhi2
		include MooseX
		requires :say
		after(:say) do |object, message|
			object.logger.after_say_2(message)
		end
	end

	module Sayhi3
		include MooseX
		requires :say
		around(:say) do |lambda, object, message|
			object.logger.around_say_2(message)
			v = lambda.call(object,message + 1)
			object.logger.around_say_2(message)
			v + 2
		end	
	end

	class Undertest
		include MooseX
		has logger: { is: :rw, required: true }

		def say(message)
			self.logger.say(message)
			message
		end

		around(:say) do |lambda, object, message|
			object.logger.around_say_1(message)
			v = lambda.call(object,message + 1)
			object.logger.around_say_1(message)
			v + 1
		end

		after(:say) do |object, message|
			object.logger.after_say_1(message)
		end

		before(:say) do |object, message|
			object.logger.before_say_1(message)
		end

		include Sayhi
		include Sayhi2
		include Sayhi3

		after(:say) do |object, message|
			object.logger.after_say_3(message)
		end		

		before(:say) do |object, message|
			object.logger.before_say_3(message)
		end

		around(:say) do |lambda, object, message|
			object.logger.around_say_3(message)
			v = lambda.call(object,message + 1)
			object.logger.around_say_3(message)
			v + 1
		end			
	end	

	class Undertest2 < Undertest
		def say(x) ; self.logger.say(x); 2*x; end
		include Sayhi; include Sayhi3
	end
end

describe "AfterBefore::Undertest" do
	it "should print two messages" do
		logger = double()

		logger.should_receive(:around_say_3).with(1).once()

		logger.should_receive(:before_say_3).with(2).once()
		
		logger.should_receive(:around_say_2).with(2).once()

		logger.should_receive(:before_say_2).with(3).once()
		
		logger.should_receive(:before_say_1).with(3).once()
		
		logger.should_receive(:around_say_1).with(3).once()

		logger.should_receive(:say).with(4).once()
		
		logger.should_receive(:around_say_1).with(3).once()
		
		logger.should_receive(:after_say_1).with(3).once()

		logger.should_receive(:after_say_2).with(3).once()
		
		logger.should_receive(:around_say_2).with(2).once()	

		logger.should_receive(:after_say_3).with(2).once()
		
		logger.should_receive(:around_say_3).with(1).once()

		u = AfterBefore::Undertest.new(logger: logger)
		u.say(1).should == 8
	end
end 

describe "AfterBefore::Undertest2" do
	it "should print two messages" do
		logger = double()
		
		logger.should_receive(:before_say_2).with(2).once()

		logger.should_receive(:around_say_2).with(1).once()
		
		logger.should_receive(:say).with(2).once()

		logger.should_receive(:around_say_2).with(1).once()
		
		u = AfterBefore::Undertest2.new(logger: logger)
		u.say(1).should == 6 # 1 -> 1+1 -> 2*2 -> 4+2
	end
end 
