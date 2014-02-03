require 'moosex'

class BuildArgsExample 
	include MooseX

	has [:x, :y], {
		is: :rw,
		required: true,
	}

	def BUILDARGS(args)
	
		args[:x] = 1024
		args[:y] = - args[:y]
		
		args
	end
end

describe "BuildArgsExample" do
	it "should create the object" do
		ex = BuildArgsExample.new(x: 10, y: -2)
		ex.x.should == 1024
		ex.y.should == 2
	end
end 

class BuildArgsExample2 
	include MooseX

	has [:x, :y], {
		is: :rw,
		required: true,
	}

	def BUILDARGS(x=4,y=8)
		args = {}
		args[:x] = x
		args[:y] = y
		
		args
	end
end

describe "BuildArgsExample2" do
	it "should create the object" do
		ex = BuildArgsExample2.new(1,2)
		ex.x.should == 1
		ex.y.should == 2
	end
	
	it "should create the object II" do
		ex = BuildArgsExample2.new(1)
		ex.x.should == 1
		ex.y.should == 8
	end	
	
	it "should create the object III" do
		ex = BuildArgsExample2.new()
		ex.x.should == 4
		ex.y.should == 8
	end	
end

class BuildArgsExample3 
	include MooseX

	has [:x, :y], {
		is: :rw,
		required: true,
	}

	def BUILDARGS(x: 4,y: 8)
		args = {}
		args[:x] = x
		args[:y] = y
		
		args
	end
end

describe "BuildArgsExample3" do
	it "should create the object" do
		ex = BuildArgsExample3.new(x: 1, y:2)
		ex.x.should == 1
		ex.y.should == 2
	end
	
	it "should create the object II" do
		ex = BuildArgsExample3.new(x: 1)
		ex.x.should == 1
		ex.y.should == 8
	end	
	
	it "should create the object III" do
		ex = BuildArgsExample3.new()
		ex.x.should == 4
		ex.y.should == 8
	end	
	
	it "should create the object III" do
		ex = BuildArgsExample3.new(y: 6)
		ex.x.should == 4
		ex.y.should == 6
	end	
end
