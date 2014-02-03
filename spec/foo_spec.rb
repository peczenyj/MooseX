require 'moosex'

class Foo
    include MooseX

    has bar: {  
      is: :rwp,       # read-write-private (private setter)
      required: true, # you should require in the constructor 
    }

    has my_other_bar: {
    	is: :rw,
    	init_arg: :bar2
    }
end

describe "Foo" do
	it "should require bar if necessary" do 
		expect {
			Foo.new
		}.to raise_error("attr \"bar\" is required")
	end

	it "should require bar if necessary" do 
		foo = Foo.new( bar: 123 )
		foo.bar.should == 123
	end

	it "should not be possible update bar (setter private)" do 
		foo = Foo.new( bar: 123 )
		expect {
			foo.bar = 1024
		}.to raise_error(NoMethodError)
	end

	it "should be possible initialize my_other_bar by bar2" do
		foo = Foo.new( bar: 1, bar2: 555)
		foo.my_other_bar.should == 555
	end
end 
