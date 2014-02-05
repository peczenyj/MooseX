require 'spec_helper'
require 'moosex'

class A
	include MooseX
end

describe "MooseX" do
	it "should contains has method" do
		A.methods.include?(:has).should be_true
	end

	it "should be possible create one single instance" do
		a = A.new
		a.is_a?(A).should be_true
	end
end