require 'moosex'

class LazyFox
	include MooseX

	has something: {
		is: :lazy
	}

	has other_thing: {
		is: :rw,
		lazy: true,
		predicate: true,
		clearer: true,
		builder: :my_build_other_thing,
	}

	has lazy_attr_who_accepts_lambda: {
		is: :lazy,
		builder: lambda{ |object| object.something }
	}

	has lazy_with_default: {
		is: :lazy,
		default: 10,
		clearer: true,
		builder: lambda {|o| 1 },
	}

	has last_lazy_attr: {
		is: :rw,
		lazy: true,
	}

	def build_something
		1024
	end

	private 
	def my_build_other_thing
		128
	end
end

describe "LazyFox" do
	it "lazy attr should be act as a normal read only attr" do
		l = LazyFox.new(something: 0)
		l.something.should == 0
	end

	it "lazy attr should be read-only" do
		l = LazyFox.new
		expect{
			l.something= 1
		}.to raise_error(NoMethodError)
	end

	it "lazy: true but is :rw should act as a defered default value" do
		l = LazyFox.new
		l.other_thing.should == 128
		l.other_thing = 9
		l.other_thing.should == 9
	end

	it "lazy: true should not exists until necessary" do
		l = LazyFox.new
		l.has_other_thing?.should be_false

		l.other_thing.should == 128

		l.has_other_thing?.should be_true
	end

	it "lazy: true :rw should build again" do
		l = LazyFox.new
		l.other_thing.should == 128

		l.has_other_thing?.should be_true

		l.clear_other_thing!

		l.has_other_thing?.should be_false 

		l.other_thing.should == 128

		l.has_other_thing?.should be_true
	end	

	it "lazy attr should call build if necessary" do
		l = LazyFox.new
		l.something.should == 1024
		l.other_thing.should == 128
	end

	it "lazy attr should accept lambda" do
		l = LazyFox.new
		l.lazy_attr_who_accepts_lambda.should == 1024
	end

	it "lazy attr should accept lambda (2)" do
		l = LazyFox.new(something: 2)
		l.lazy_attr_who_accepts_lambda.should == 2
	end	

	it "lazy_with_default should be initialize with default value" do
		l = LazyFox.new
		l.lazy_with_default.should == 10
		l.clear_lazy_with_default!
		l.lazy_with_default.should == 1
	end

	it "last_lazy_attr will raise error without a builder" do
		l = LazyFox.new
		expect {
			l.last_lazy_attr
		}.to raise_error(NoMethodError)
	end

	it "last_lazy_attr will not raise error with a builder" do
		l = LazyFox.new
		def l.build_last_lazy_attr
			0
		end
		l.last_lazy_attr.should be_zero
	end
end
