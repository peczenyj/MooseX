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

	def clear 
		self.x= 0        # to run with type-check you must
		self.y= 0        # use the setter instad @x=
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
			}.to raise_error('isa check for "x" failed: is not instance of Integer!')
		end	
		
		it "for x, with type check" do			
			expect { 
				Point.new(x: "lol") 
			}.to raise_error('isa check for "x" failed: is not instance of Integer!')
		end	

		it "clear should clean attributes" do
			p = Point.new( x: 5, y: 4)
			p.clear
			p.x.should be_zero
			p.y.should be_zero			
		end	
	end	
end

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

class Baz
    include MooseX

    has bam: {
      is: :ro,             # read-only, you should specify in new only
      isa: lambda do |bam| # you should add your own validator
          raise 'bam should be less than 100' if bam > 100
      end,
      required: true,
    }

	has boom: {
		is: :rw,
    predicate: true,     # add has_boom? method, ask if the attribute is unset
    clearer: true,       # add clear_boom! method, unset the attribute
	}
end

describe "Baz" do
	it "should require bam if necessary" do 
		baz = Baz.new( bam: 99 )
		baz.bam.should == 99
	end

	it "should not be possible update baz (read only)" do 
		baz = Baz.new( bam: 99 )
		expect {
			baz.bam = 1024
		}.to raise_error(NoMethodError)
	end

	it "should run the lambda isa" do 
		expect {
			Baz.new( bam: 199 )
		}.to raise_error(/bam should be less than 100/)
	end

	it "should inject methods in the class (predicate)" do
		baz = Baz.new( bam: 99 )
		
		baz.respond_to?(:has_boom?).should be_true
		Baz.instance_methods.member?(:has_boom?).should be_true	
	end
	
	it "should inject methods in the class (clearer)" do
		baz = Baz.new( bam: 99 )
		
		baz.respond_to?(:clear_boom!).should be_true
		Baz.instance_methods.member?(:clear_boom!).should be_true			
	end

	it "rw acessor should has nil value, supports predicate" do
		baz = Baz.new( bam: 99 )
		
		baz.has_boom?.should be_false
		baz.boom.should be_nil
		baz.boom= 0
		baz.has_boom?.should be_true
		baz.boom.should be_zero
	end

	it "rw acessor should has nil value, supports clearer" do
		baz = Baz.new( bam: 99, boom: 0 )
		
		baz.has_boom?.should be_true
		baz.boom.should be_zero
		
		baz.clear_boom!

		baz.has_boom?.should be_false
		baz.boom.should be_nil
	end	

	it "should be possible call the clearer twice" do
		baz = Baz.new( bam: 99, boom: 0 )
		
		baz.clear_boom!
		baz.clear_boom!
		
		baz.has_boom?.should be_false
		baz.boom.should be_nil
	end		
end

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

class ProxyToTarget
	include MooseX

	has target: {
		is:  :ro,
		default: lambda { Target.new }, # default, new instace of Target
		handles: {                      # handles is for delegation,
			my_method_x: :method_x,       # inject methods with new names 
			my_method_y: :method_y,	      # old => obj.target.method_x
		},                              # now => obj.my_method_x
	}
end

module TargetModule
	def method_x; 1024; end             # works with simple methods
	def method_y(a,b,c); a + b + c; end # or methods with arguments
end

class Target 
	include TargetModule
end

describe "ProxyToTarget" do
	it "should delegate method_x to the target" do
		p = ProxyToTarget.new

		p.target.method_x.should == 1024
		p.my_method_x.should == 1024
	end

	it "should delegate method_y to the target" do
		p = ProxyToTarget.new

		p.target.method_y(1,2,3).should == 6
		p.my_method_y(1,2,3).should == 6
	end	
	
	it "should inject method_y" do
		p = ProxyToTarget.new
		
		p.respond_to?(:my_method_y).should be_true
		ProxyToTarget.instance_methods.member?(:my_method_y).should be_true
	end
end

class ProxyToTargetUsingArrayOfMethods
	include MooseX

	has targetz: {
		is:  :ro,
		default: lambda { Target.new }, 
		handles: [ 
			:method_x, :method_y      # will inject all methods with same name
		] 
	}
end

describe "ProxyToTargetUsingArrayOfMethods" do
	it "should delegate method_x to the target" do
		p = ProxyToTargetUsingArrayOfMethods.new

		p.targetz.method_x.should == 1024
		p.method_x.should == 1024
	end

	it "should delegate method_y to the target" do
		p = ProxyToTargetUsingArrayOfMethods.new

		p.targetz.method_y(1,2,3).should == 6
		p.method_y(1,2,3).should == 6
	end	
end

class ProxyToTargetUsingSingleMethod
	include MooseX

	has target: {
		is:  :ro,
		default: lambda { Target.new }, 
		handles: "method_x"         # coerce to an array of symbols
	}
end

describe "ProxyToTargetUsingSingleMethod" do
	it "should delegate method_x to the target" do
		p = ProxyToTargetUsingSingleMethod.new

		p.target.method_x.should == 1024
		p.method_x.should == 1024
	end
end

class ProxyToTargetUsingModule
	include MooseX

	has target: {
		is:  :ro,
		default: lambda { Target.new }, 
		handles: TargetModule          # will import all methods from module
	}
end

describe "ProxyToTargetUsingModule" do
	it "should delegate method_x to the target" do
		p = ProxyToTargetUsingModule.new

		p.target.method_x.should == 1024
		p.method_x.should == 1024
	end

	it "should delegate method_y to the target" do
		p = ProxyToTargetUsingModule.new

		p.target.method_y(1,2,3).should == 6
		p.method_y(1,2,3).should == 6
	end		
end

class ProxyToTargetUsingClass
	include MooseX

	has target: {
		is:  :ro,
		default: lambda { Target.new }, 
		handles: Target                   # will use only public methods on Target class
	}                                   # exclude methods from superclass
end

describe "ProxyToTargetUsingClass" do
	it "should delegate method_x to the target" do
		p = ProxyToTargetUsingClass.new

		p.target.method_x.should == 1024
		p.method_x.should == 1024
	end

	it "should delegate method_y to the target" do
		p = ProxyToTargetUsingClass.new

		p.target.method_y(1,2,3).should == 6
		p.method_y(1,2,3).should == 6
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
			}.to raise_error('isa check for "z" failed: is not instance of Integer!')
		end	
		
		it "for z, with type check" do			
			expect { 
				Point3D.new(z: "lol") 
			}.to raise_error('isa check for "z" failed: is not instance of Integer!')
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

class LazyFox
	include MooseX

	has something: {
		is: :lazy
	}

	has other_thing: {
		is: :rw,
		lazy: true,
		predicate: true,
		clearer: true,
		builder: :my_build_other_thing,
	}

	has lazy_attr_who_accepts_lambda: {
		is: :lazy,
		builder: lambda{ |object| object.something }
	}

	has lazy_with_default: {
		is: :lazy,
		default: 10,
		clearer: true,
		builder: lambda {|o| 1 },
	}

	has last_lazy_attr: {
		is: :rw,
		lazy: true,
	}

	def build_something
		1024
	end

	private 
	def my_build_other_thing
		128
	end
end

describe "LazyFox" do
	it "lazy attr should be act as a normal read only attr" do
		l = LazyFox.new(something: 0)
		l.something.should == 0
	end

	it "lazy attr should be read-only" do
		l = LazyFox.new
		expect{
			l.something= 1
		}.to raise_error(NoMethodError)
	end

	it "lazy: true but is :rw should act as a defered default value" do
		l = LazyFox.new
		l.other_thing.should == 128
		l.other_thing = 9
		l.other_thing.should == 9
	end

	it "lazy: true should not exists until necessary" do
		l = LazyFox.new
		l.has_other_thing?.should be_false

		l.other_thing.should == 128

		l.has_other_thing?.should be_true
	end

	it "lazy: true :rw should build again" do
		l = LazyFox.new
		l.other_thing.should == 128

		l.has_other_thing?.should be_true

		l.clear_other_thing!

		l.has_other_thing?.should be_false 

		l.other_thing.should == 128

		l.has_other_thing?.should be_true
	end	

	it "lazy attr should call build if necessary" do
		l = LazyFox.new
		l.something.should == 1024
		l.other_thing.should == 128
	end

	it "lazy attr should accept lambda" do
		l = LazyFox.new
		l.lazy_attr_who_accepts_lambda.should == 1024
	end

	it "lazy attr should accept lambda (2)" do
		l = LazyFox.new(something: 2)
		l.lazy_attr_who_accepts_lambda.should == 2
	end	

	it "lazy_with_default should be initialize with default value" do
		l = LazyFox.new
		l.lazy_with_default.should == 10
		l.clear_lazy_with_default!
		l.lazy_with_default.should == 1
	end

	it "last_lazy_attr will raise error without a builder" do
		l = LazyFox.new
		expect {
			l.last_lazy_attr
		}.to raise_error(NoMethodError)
	end

	it "last_lazy_attr will not raise error with a builder" do
		l = LazyFox.new
		def l.build_last_lazy_attr
			0
		end
		l.last_lazy_attr.should be_zero
	end
end

class CoerceTest
	include MooseX

	has attribute_ro: {
		is: :ro,
		isa: Integer,
		coerce: lambda {|value| value.to_i },
	}

	has attribute_rw: {
		is: :rw,
		isa: Integer,
		coerce: lambda {|value| value.to_i },
	}

	has attribute_lazy: {
		is: :lazy,
		isa: Integer,
		coerce: lambda {|value| value.to_i },
		builder: lambda{|object| "2048" },
	}

	def trigger_attr(new_value)
		puts "change value of attribute to #{new_value}"
	end
end

describe "CoerceTest" do
	it "should coerce the argument using to_i on constructor" do
		ct = CoerceTest.new(attribute_ro: "12")
		ct.attribute_ro.should == 12
	end

	it "should coerce the argument using to_i on constructor" do
		ct = CoerceTest.new(attribute_rw: "12")
		ct.attribute_rw.should == 12
	end

	it "should coerce in the setter" do
		ct = CoerceTest.new
		ct.attribute_rw= "128"
		ct.attribute_rw.should == 128
	end

	it "should coerce from builder" do
		ct = CoerceTest.new
		ct.attribute_lazy.should == 2048
	end
end

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
		trigger: lambda do |object, new_value| 
			object.logger.log "will update attr_with_trigger with new value #{new_value}"
		end,
		default: 1,
	}

	has attr_lazy_trigger: {
		is: :lazy,
		trigger: :my_method,
		builder: lambda{ |x| 1},
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