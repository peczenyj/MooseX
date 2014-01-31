#require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'moosex'

class Point
	include MooseX
	
	has :x , {
		:is => :rw,
		:isa => Integer,
		:default => 0,
	}

	has :y , {
		:is => :rw,
		:isa => Integer,
		:default => lambda { 0 },
	}
	
	def clear 
		self.x= 0
		self.y= 0
	end
end

describe "Point" do
	describe "should has an intelligent constructor" do
		it "without arguments, should initialize with default values" do
			p = Point.new
			p.x.should be_zero
			p.y.should be_zero
		end
	
		it "should initialize only y" do
			p = Point.new( :x => 5 )
			p.x.should == 5
			p.y.should be_zero
		end
	
		it "should initialize x and y" do
			p = Point.new( :x => 5, :y => 4)
			p.x.should == 5
			p.y.should == 4
		end
	end
	
	describe "should create a getter and a setter" do
		it "for x" do
			p = Point.new
			p.x= 5
			p.x.should == 5
		end		
		
		it "for x, with type check" do
			p = Point.new
			expect { p.x = "lol" }.to raise_error('isa check for "x" failed: lol is not Integer!')
		end	
		
		it "clear should clean attributes" do
			p = Point.new( :x => 5, :y => 4)
			p.clear
			p.x.should be_zero
			p.y.should be_zero			
		end	
	end	
end