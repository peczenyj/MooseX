require 'moosex'

class ProxyToTarget
  include MooseX

  has target: {
    is:  :ro,
    default: lambda { Target.new },  # default, new instace of Target
    handles: {                       # handles is for delegation,
      my_method_x: :method_x,        # inject methods with new names 
      my_method_y: :method_y,        # old => obj.target.method_x , now => obj.my_method_x
      my_method_y_with_1: {          # currying!!!  
        method_y: 1,                 # call obj.mymethod_z(2,3) is the equivalent to
      },                             # call obj.target.method_z(1,2,3)
      my_method_y_with_lambda: {     # currying!!!  
        method_y: lambda{ 1 },       # call obj.mymethod_z(2,3) is the equivalent to
      },                             # call obj.target.method_z(1,2,3)
      my_method_z_with_array: {
        method_z: [1,lambda{ 2 } ,3]
      },
      my_method_k_with_literal_array: {
        method_k: [[1,2,3]]
      },
      my_method_k_with_literal_array2: {
        method_k: [ lambda{  [1,2,3] } ]
      },
      my_method_k_with_literal_array3: {
        method_k: lambda{  [[1,2,3]] } 
      }            
    }
  }
end

module TargetModule
  def method_x; 1024; end             # works with simple methods
  def method_y(a,b,c); a + b + c; end # or methods with arguments
  def method_z(*args); args.reduce(:+); end
  def method_k(array); array.count; end
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

  it "should delegate method_y to the target with currying" do
    p = ProxyToTarget.new

    p.target.method_y(1,2,3).should == 6
    p.my_method_y_with_1(2,3).should == 6
  end

  it "should delegate method_y to the target with currying as lambda" do
    p = ProxyToTarget.new

    p.target.method_y(1,2,3).should == 6
    p.my_method_y_with_lambda(2,3).should == 6
  end

  it "should delegate method_z to the target with currying (many args) as lambda" do
    p = ProxyToTarget.new

    p.target.method_z(1,2,3,4).should == 10
    p.my_method_z_with_array(4).should == 10
  end

  it "should delegate method_k to the target with currying (many args)" do
    p = ProxyToTarget.new

    p.target.method_k([1,2,3]).should == 3
    p.my_method_k_with_literal_array().should == 3
  end
  
  it "should delegate method_k to the target with currying (many args) as lambda" do
    p = ProxyToTarget.new

    p.target.method_k([1,2,3]).should == 3
    p.my_method_k_with_literal_array2().should == 3
  end

  it "should delegate method_k to the target with currying (many args) as lambda (2)" do
    p = ProxyToTarget.new

    p.target.method_k([1,2,3]).should == 3
    p.my_method_k_with_literal_array3().should == 3
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
