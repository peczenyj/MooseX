require 'moosex'
require 'moosex/types'

module TestTrait
  class MyHomePage
    include MooseX
    include MooseX::Types

    has :counter, {
      is: :ro,
      isa: Integer,
      default: 0,
      traits: MooseX::Traits::Counter,
      handles: {
        inc_counter: :inc,
        dec_counter: :dec,
        reset_counter!: :reset,
      }
    }

    has :counter_rw, {
      is: :rw,
      isa: Integer,
      default: 0,
      traits: [ MooseX::Traits::Counter ],
      handles: {
        inc_counter_rw: :inc,
        dec_counter_rw: :dec,
        reset_counter_rw!: :reset,
      }
    }

    has :lazy_counter, {
      is: :lazy,
      isa: Integer,
      traits: [ MooseX::Traits::Counter ],
      handles: {
        lazy_inc_counter: :inc,
        lazy_dec_counter: :dec,
        lazy_reset_counter!: :reset,
      },
      clearer: true,
    }

    has surname_name: {
      is: :private,
      isa: isTuple(String, String),
      traits: [ MooseX::Traits::Pair ],
      handles: {
        surname: :first,
        name: :second,
        :surname= => :first=,
        :name= => :second=,
        surname_and_name: { join: ->{","} }
      }
    }

    has __bit__: {
      is: :private,
      default: true,
      traits: MooseX::Traits::Bool,
      handles: {
        :bit_toggle!   => :toggle!,
        :bit_turn_on!  => :set!,
        :bit_turn_off! => :unset!,
        :bit_on?       => :value,
        :bit_off?      => :not,      
      },
      init_arg: :bit,
    }
    
    has session: {
      is: :rw,
      default: -> { {} },
      coerce: ->(value) { ((value.is_a?(Array))? value : [value, 3]) },
      traits: MooseX::Traits::Expires,
    }

    def build_lazy_counter
      0
    end
  end
end

describe TestTrait::MyHomePage do
  it "should accept valid session" do
    page = TestTrait::MyHomePage.new
    page.session.valid?.should be_true
    page.session.should == {}
    sleep(3)
    page.session.valid?.should be_false
    page.session= { bar: 5 }
    page.session.valid?.should be_true
    page.session.should == { bar: 5 }
    sleep(3)
    page.session.valid?.should be_false     
  end
  
  it "should increase counter" do
    page = TestTrait::MyHomePage.new(counter: 0)
    page.counter.should be_zero
    page.inc_counter
    page.counter.should == 1

    page.inc_counter(3)
    page.counter.should == 4

    page.dec_counter
    page.counter.should == 3

    page.dec_counter(2)
    page.counter.should == 1

    page.reset_counter!
    page.counter.should be_zero

    page.inc_counter(5)
    (page.counter * 8).should == 40 
  end

  it "should increase counter by default value" do
    page = TestTrait::MyHomePage.new
    page.counter.should be_zero
    page.inc_counter
    page.counter.should == 1

    page.inc_counter(3)
    page.counter.should == 4

    page.dec_counter
    page.counter.should == 3

    page.dec_counter(2)
    page.counter.should == 1

    page.reset_counter!
    page.inc_counter
    page.counter.should == 1
  end  

  it "should increase counter_rw by default value" do
    page = TestTrait::MyHomePage.new
    page.counter_rw.should be_zero
    page.inc_counter_rw
    page.counter_rw.should == 1

    page.counter_rw = 4
    page.counter_rw.should == 4

    page.dec_counter_rw
    page.counter_rw.should == 3

    page.dec_counter_rw(2)
    page.counter_rw.should == 1

    page.reset_counter_rw!
    page.counter_rw.should be_zero
  end  

   it "should increase lazy_counter if lazy" do
    page = TestTrait::MyHomePage.new
    page.lazy_counter.should be_zero
    page.lazy_inc_counter
    page.lazy_counter.should == 1

    page.lazy_inc_counter(3)
    page.lazy_counter.should == 4

    page.lazy_dec_counter
    page.lazy_counter.should == 3

    page.lazy_dec_counter(2)
    page.lazy_counter.should == 1

    page.lazy_reset_counter!
    page.lazy_counter.should be_zero

    page.clear_lazy_counter!
    page.lazy_counter.should be_zero
    page.lazy_inc_counter
    page.lazy_counter.should == 1
  end 

  it "should store name, surname " do
    page = TestTrait::MyHomePage.new(surname_name: ["Smith", "John"])

    page.name.should == "John"
    page.surname.should == "Smith"
    page.surname_and_name.should == "Smith,John"

    page.name= "Karl"
    page.surname="Popper"

    page.name.should == "Karl"
    page.surname.should == "Popper"
    page.surname_and_name.should == "Popper,Karl"

    expect { 
      page.surname_name.count.should == 2
    }.to raise_error(NoMethodError)
  end

  it "bit should act as a boolean in arg list" do
    page = TestTrait::MyHomePage.new(bit: false)
    page.bit_on?.should  be_false
  end
  
  it "bit should act as a boolean" do
    page = TestTrait::MyHomePage.new
    page.bit_on?.should  be_true
    page.bit_toggle!
    page.bit_on?.should  be_false
    page.bit_off?.should be_true
    
    page.bit_turn_on!
    page.bit_on?.should be_true

    unless page.bit_on?
      raise "should act as a true value"
    end
    page.bit_turn_off!
    page.bit_on?.should be_false

    if page.bit_on?
      raise "should act as a false value"
    end
  end     
end  
  