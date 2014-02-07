require 'moosex'

class Hooks
	include MooseX

	has logger: {
		is: :rw,
		required: true,
	}

	def sum(a,b,c)
		self.logger.inside_method(a,b,c)
		a + b + c
	end

	before(:sum) do |object,a,b,c|
		object.logger.inside_before(a,b,c)
	end

	after(:sum) do |object,a,b,c|
		object.logger.inside_after(a,b,c)
	end
end

describe "Hooks" do
	it "should call after and before" do
		logger = double
		logger.should_receive(:inside_method).with(1,2,3)
		logger.should_receive(:inside_before).with(1,2,3)
		logger.should_receive(:inside_after).with(1,2,3)

		h = Hooks.new(logger: logger)
		h.sum(1,2,3).should == 6
	end
end

class Hooks2 < Hooks
	around(:sum) do |method_lambda, object, a,b,c|
		object.logger.inside_around_begin(a,b,c)
		result = method_lambda.call(object,a,b,c)
		object.logger.inside_around_end(a,b,c)
		result + 1
	end

	after(:sum) do |object,a,b,c|
		object.logger.inside_after2(a,b,c)
	end	
end

describe "Hooks2" do
	it "should call after and before" do
		logger = double
		logger.should_receive(:inside_method).with(1,2,3)
		logger.should_receive(:inside_before).with(1,2,3)
		logger.should_receive(:inside_after).with(1,2,3)
		logger.should_receive(:inside_after2).with(1,2,3)		
		logger.should_receive(:inside_around_begin).with(1,2,3)
		logger.should_receive(:inside_around_end).with(1,2,3)
		h = Hooks2.new(logger: logger)
		h.sum(1,2,3).should == 7
	end
end

class OtherPoint 
	include MooseX

	has [:x, :y ], { is: :rw, required: true }

	def clear!
		self.x = 0
		self.y = 0
	end
end

class OtherPoint3D < OtherPoint

	has z: { is: :rw, required: true }

	after :clear! do |object|
		object.z = 0
	end
end

describe "OtherPoint3D" do
	it "should clear a 3d point" do 
		p = OtherPoint3D.new(x: 1, y: 2, z: 3)
		p.x.should == 1
		p.y.should == 2
		p.z.should == 3

		p.clear!

		p.x.should == 0
		p.y.should == 0
		p.z.should == 0
	end
end	

class OtherPoint4D < OtherPoint3D

	has t: { is: :rw, required: true }

	after :clear! do |object|
		object.t = 0
	end
end

describe "OtherPoint4D" do
	it "should clear a 3d point" do 
		p = OtherPoint4D.new(x: 1, y: 2, z: 3, t: 4)
		p.x.should == 1
		p.y.should == 2
		p.z.should == 3
		p.t.should == 4

		p.clear!

		p.x.should == 0
		p.y.should == 0
		p.z.should == 0
		p.t.should == 0		
	end
end

module ModuleHWB
  include MooseX
  
  requires :info
  
  around(:call_with) do |original, object,x,&proc|
    object.info(1,x)
    
    result= original.call(object,x,&proc)
    
    object.info(2,result)
    
    result
  end

  before(:call_with) do |object,x, &k|
    object.info(3, x)
  end  

  after(:call_with) do |object,x,&k|
    object.info(4, x)
  end
end

class HooksWithBlocks
  include MooseX

  has logger: { is: :rw, handles: :info }
    
  def call_with(x)
    yield(x)
    #proc.call(x)
  end  
    
  include ModuleHWB
end

class HooksWithBlocks2
  include MooseX
  
  has logger: { is: :rw, handles: :info }
  
  def call_with(x, &proc)
    #yield(x)
    proc.call(x)
  end  
    
  around(:call_with) do |original, object,x,&proc|
    object.info(1,x)
    
    result= original.call(object,x,&proc)
    
    object.info(2,result)
    
    result
  end

  before(:call_with) do |object,x, &k|
    object.info(3, x)
  end  

  after(:call_with) do |object,x,&k|
    object.info(4, x)
  end
end

describe HooksWithBlocks do
  it "should call all hooks" do
    logger = double
    logger.should_receive(:info).with(3,7).once()
    logger.should_receive(:info).with(1,7).once()
    logger.should_receive(:info).with(2,8).once()
    logger.should_receive(:info).with(4,7).once()
    
    x = HooksWithBlocks.new(logger: logger)
    x.call_with(7){|x| x+1}
  end
end

describe HooksWithBlocks2 do
  it "should call all hooks" do
    logger = double
    logger.should_receive(:info).with(3,7).once()
    logger.should_receive(:info).with(1,7).once()
    logger.should_receive(:info).with(2,8).once()
    logger.should_receive(:info).with(4,7).once()

    x = HooksWithBlocks2.new(logger: logger)
    x.call_with(7) do |x| 
      x+1
    end  
  end
end
