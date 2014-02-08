require 'moosex'

class BuildExample 
	include MooseX

	has [:x, :y], {
		is: :rw,
		required: true,
	}
	def BUILD
		if self.x == self.y 
			raise "invalid: you should use x != y"
		end 
	end
end

describe "BuildExample" do
	it "should raise exception on build" do
		expect {
			BuildExample.new(x: 0, y: 0)
			}.to raise_error(/invalid: you should use x != y/)
	end
end
