require 'moosex'
require 'moosex/types'

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
	
	has secret: {
		is: :private,
	}
 	
	def clear 
		self.x= 0        # to run with type-check you must
		self.y= 0        # use the setter instad @x=
	end

  def change_secret(new_secret)
		self.secret= new_secret
	end

	def show_secret
		secret
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
			p = Point.new( x: 5 )
			p.x.should == 5
			p.y.should be_zero
		end
	
		it "should initialize x and y" do
			p = Point.new( x: 5, y: 4)
			p.x.should == 5
			p.y.should == 4
		end
  end

  describe "private accessors" do		
		it "should change private by method" do
			p = Point.new(secret: 1)
			p.show_secret.should == 1
			p.change_secret(2)
			p.show_secret.should == 2
		end
		
		it "cant read secret" do
			p = Point.new
			expect {
				p.secret
			}.to raise_error(NoMethodError)
		end
		
		it "cant write secret" do
			p = Point.new
			expect {
				p.secret = 1
			}.to raise_error(NoMethodError)
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
			expect { 
				p.x = "lol" 
			}.to raise_error(MooseX::Types::TypeCheckException,
				"isa check for x=: Type violation: value 'lol' (String) is not an instance of [Type Integer]")
		end	
		
		it "for x, with type check" do			
			expect { 
				Point.new(x: "lol") 
			}.to raise_error(MooseX::Types::TypeCheckException,
				"isa check for field x: Type violation: value 'lol' (String) is not an instance of [Type Integer]")
		end	

		it "clear should clean attributes" do
			p = Point.new( x: 5, y: 4)
			p.clear
			p.x.should be_zero
			p.y.should be_zero			
		end	
	end	
end

class Point3D < Point

	has x: {        # override original attr!
		is: :rw,
		isa: Integer,
		default: 1,
	}
	
	has z: {
		is: :rw,      # read-write (mandatory)
		isa: Integer, # should be Integer
		default: 0,   # default value is 0 (constant)
	}

	has color: {
		is: :rw,      # you should specify the reader/writter
		reader: :what_is_the_color_of_this_point,
		writter: :set_the_color_of_this_point,
		default: :red,
	}

	def clear 
		self.x= 0      # to run with type-check you must
		self.y= 0      # use the setter instad @x=
		self.z= 0
	end
end 

describe "Point3D" do
	describe "should has an intelligent constructor" do
		it "without arguments, should initialize with default values" do
			p = Point3D.new
			p.x.should == 1
			p.y.should be_zero
			p.z.should be_zero
			p.what_is_the_color_of_this_point.should == :red
		end
	
		it "should initialize only y" do
			p = Point3D.new( x: 5 )
			p.x.should == 5
			p.y.should be_zero
			p.z.should be_zero
			p.what_is_the_color_of_this_point.should == :red						
		end
	
		it "should initialize x and y" do
			p = Point3D.new( x: 5, y: 4, z: 8, color: :yellow)
			p.x.should == 5
			p.y.should == 4
			p.z.should == 8
			p.what_is_the_color_of_this_point.should == :yellow			
		end
	end
	
	describe "should create a getter and a setter" do
		it "for z" do
			p = Point3D.new
			p.z= 5
			p.z.should == 5
		end		
		
		it "for z, with type check" do
			p = Point3D.new
			expect { 
				p.z = "lol" 
			}.to raise_error(MooseX::Types::TypeCheckException,
				"isa check for z=: Type violation: value 'lol' (String) is not an instance of [Type Integer]")
		end	
		
		it "for z, with type check" do			
			expect { 
				Point3D.new(z: "lol") 
			}.to raise_error(MooseX::Types::TypeCheckException,
				"isa check for field z: Type violation: value 'lol' (String) is not an instance of [Type Integer]")
		end	

		it "clear should clean attributes" do
			p = Point3D.new( x: 5, y: 4, z: 9)
			p.clear
			p.x.should be_zero
			p.y.should be_zero	
			p.z.should be_zero			
		end	
	end	

	describe "should create the accessors names with custom names" do
		it "should get/set" do
			p = Point3D.new
			p.what_is_the_color_of_this_point.should == :red
			p.set_the_color_of_this_point(:black)
			p.what_is_the_color_of_this_point.should == :black
		end
	end
end
