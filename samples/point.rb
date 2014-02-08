#
# This example was ported from
# https://metacpan.org/pod/Moose::Cookbook::Basics::Point_AttributesAndSubclassing 

require 'moosex'

class Point
	include MooseX

	has x: {
		is: :rw,      # read-write (mandatory)
		isa: Integer, # should be Integer
		default: 0,   # default value is 0 (constant)
	}

	has y: {
		is: :rw,
		isa: Integer,
		default: lambda { 0 }, # you should specify a lambda
	}

	def clear! 
		self.x= 0      # to run with type-check you must
		self.y= 0      # use the setter instad @x=
	end

	def to_s
		"Point[x=#{self.x}, y=#{self.y}]"
	end	
end 

class Point3D < Point	
	has z: {
		is: :rw,      # read-write (mandatory)
		isa: Integer, # should be Integer
		default: 0,   # default value is 0 (constant)
	}

	def clear! 
		self.x= 0      # to run with type-check you must
		self.y= 0      # use the setter instad @x=
		self.z= 0
	end

	def to_s
		"Point[x=#{self.x}, y=#{self.y}, z=#{self.z}]"
	end		
end 

p1 = Point.new(x: 4, y:5)
p2 = Point.new()
p3 = Point3D.new(x: 4, y:5, z:6)
p4 = Point3D.new(x: 4, y:5)
p5 = Point3D.new()

puts ">> objects"
puts p1, p2, p3, p4, p5

p1.clear!
p3.clear!

puts ">> clear"
puts p1, p3
