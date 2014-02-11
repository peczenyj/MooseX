require 'spec_helper'
require 'moosex'

class A
	include MooseX

	has :foo

	has :bar, { doc: "bar..."}
end

class B < A

	has :bar, { doc: "new Bar... ", override: true }
end

describe "MooseX" do
	it "should contains has method" do
		A.methods.include?(:has).should be_true
	end

	it "should be possible create one single instance" do
		a = A.new
		a.is_a?(A).should be_true
	end

	it "A should has an attribute foo" do
		a = A.new(foo: 1)
		a.foo.should == 1
		a.foo = 6
		a.foo.should == 6
	end

	it "B should has an attribute foo" do
		a = B.new(foo: 1)
		a.foo.should == 1
		a.foo = 6
		a.foo.should == 6
	end	
end
