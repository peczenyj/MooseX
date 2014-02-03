require 'moosex'

class Lol 
    include MooseX

    has [:a, :b], {          # define attributes a and b
      is: :ro,               # with same set of properties
      default: 0,      
    }

    has c: {                 # alternative syntax to be 
      is: :ro,               # more similar to Moo/Moose    
      default: 1,
      predicate: :can_haz_c?,     # custom predicate
      clearer: "desintegrate_c",  # force coerce to symbol
    }

	has [:d, :e] => {
		is: "ro",           # can coerce from strings
		default: 2,
		required: true,		
	}    
end

describe "Lol" do
	it "Lol should has five arguments" do
		lol = Lol.new(a: 5, d: -1)
		lol.a.should == 5
		lol.b.should be_zero
		lol.c.should == 1
		lol.d.should == -1
		lol.e.should == 2
	end

	it "Lol should support custom predicate and clearer" do
		lol = Lol.new(a: 5, d: -1)

		lol.can_haz_c?.should be_true
		lol.desintegrate_c
		lol.can_haz_c?.should be_false
	end
end