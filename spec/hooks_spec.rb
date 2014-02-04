require 'moosex'

class Hooks
	include MooseX

	has logger: {
		is: :rw,
		required: true,
	}

	def sum(a,b,c)
		self.logger.inside_method(a,b,c)
		a + b + c
	end

	before(:sum) do |object,a,b,c|
		object.logger.inside_before(a,b,c)
	end

	after(:sum) do |object,a,b,c|
		object.logger.inside_after(a,b,c)
	end
end

describe "Hooks" do
	it "should call after and before" do
		logger = double
		logger.should_receive(:inside_method).with(1,2,3)
		logger.should_receive(:inside_before).with(1,2,3)
		logger.should_receive(:inside_after).with(1,2,3)

		h = Hooks.new(logger: logger)
		h.sum(1,2,3).should == 6
	end
end

class Hooks2 < Hooks
	around(:sum) do |original_method, object, a,b,c|
		object.logger.inside_around_begin(a,b,c)
		result = original_method.bind(object).call(a,b,c)
		object.logger.inside_around_end(a,b,c)
		result + 1
	end

	after(:sum) do |object,a,b,c|
		object.logger.inside_after2(a,b,c)
	end	
end

describe "Hooks2" do
	it "should call after and before" do
		logger = double
		logger.should_receive(:inside_method).with(1,2,3)
		logger.should_receive(:inside_before).with(1,2,3)
		logger.should_receive(:inside_after).with(1,2,3)
		logger.should_receive(:inside_after2).with(1,2,3)		
		logger.should_receive(:inside_around_begin).with(1,2,3)
		logger.should_receive(:inside_around_end).with(1,2,3)
		h = Hooks2.new(logger: logger)
		h.sum(1,2,3).should == 7
	end
end