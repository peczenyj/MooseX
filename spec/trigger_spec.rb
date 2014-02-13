require 'moosex'

class TriggerTest
	include MooseX

	has logger: {
		is: :ro
	}

	has attr_with_trigger: {
		is: :rw,
		trigger: :my_method,
	}

	has attr_with_trigger_ro: {
		is: :ro,
		trigger: :my_method,
	}

	has attr_with_default: {
		is: :rw,
		trigger: ->(this, new_value) do
			this.logger.log "will update attr_with_trigger with new value #{new_value}"
		end,
		default: 1,
	}

	has attr_lazy_trigger: {
		is: :lazy,
		trigger: :my_method,
		builder: ->(this) { 1 },
	}

	def my_method(new_value)
		logger.log "will update attr_with_trigger with new value #{new_value}"
	end
end

describe "TriggerTest" do
	it "should call trigger on constructor" do
		log = double
		log.should_receive(:log)
		t = TriggerTest.new(attr_with_trigger: 1, logger: log)

	end

	it "should call trigger on constructor (ro)" do
		log = double
		log.should_receive(:log)
		t = TriggerTest.new(attr_with_trigger_ro: 1, logger: log)

	end

	it "should NOT call trigger on constructor (with default)" do
		log = double
		log.should_not_receive(:log)
		t = TriggerTest.new(logger: log)
	end

	it "should NOT call trigger on constructor (with default)" do
		log = double
		log.should_receive(:log)
		t = TriggerTest.new(logger: log)

		t.attr_with_default = 1
	end

	it "should call trigger on setter" do
		log = double
		log.should_receive(:log)
		t = TriggerTest.new(logger: log)
		
		t.attr_with_trigger = 1
	end

	it "should call trigger on setter" do
		log = double
		log.should_receive(:log)
		t = TriggerTest.new(logger: log)
		
		t.attr_lazy_trigger.should == 1
	end	
end
