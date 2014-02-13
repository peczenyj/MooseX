require 'spec_helper'
require 'moosex'

class Baz
    include MooseX

    has bam: {
      is: :ro,             # read-only, you should specify in new only
      isa: ->(bam) do      # you should add your own validator
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
