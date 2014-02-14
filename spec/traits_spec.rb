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

    has bit: {
      is: :ro,
      default: true,
      traits: MooseX::Traits::Bool,
      handles: [ :toggle!, :not, :set!, :unset!, :value ],
    }

    has important: {
      is: :rw,
      default: nil,
      traits: MooseX::Traits::RescueToNil,
      handles: {
        plus: :+,
        minus: :-,
      }
    }

    has important2: {
      is: :rw,
      default: nil,
      traits: MooseX::Traits::RescueToZero,
      handles: {
        plus2: :+,
        minus2: :-,
      }
    }

    has phrase: {
      is: :rw,
      default: nil,
      traits: MooseX::Traits::RescueToEmptyString,
      handles: {
        upcase_phrase: :upcase
      }
    }

    def build_lazy_counter
      0
    end
  end

  class ComplexExample
    include MooseX
    include MooseX::Types

    has surname_name: {
      is: :rw,
      isa: isMaybe(isTuple(String, String)),
      default: nil,
      traits: [ MooseX::Traits::RescueToEmptyString, MooseX::Traits::Pair ],
      handles: {
        surname: :first,
        name: :second,
        :surname= => :first=,
        :name= => :second=,
        surname_and_name: { join: ->{", "} }
      }
    }
  end
end

describe TestTrait::ComplexExample do
  it "should be possible call surname_and_name" do
    ce = TestTrait::ComplexExample.new(surname_name: ["Asimov", "Isaac"])
    ce.name.should == "Isaac"
    ce.surname_and_name.should == "Asimov, Isaac"
  end

  it "should be possible call surname_and_name if nil" do
    ce = TestTrait::ComplexExample.new(surname_name: nil)
    ce.name.should == ""    
    ce.surname_and_name.should == ", "
  end  

  it "should be possible call surname_and_name if nil 2" do
    ce = TestTrait::ComplexExample.new(surname_name: nil)
    ce.name.should == ""    
    ce.surname_and_name.should == ", "

    ce.name= "Isaac"
    ce.surname_and_name.should == ", Isaac"
    ce.surname= "Asimov"
    ce.surname_and_name.should == "Asimov, Isaac"
    
    ce.surname_name= nil
    ce.name.should == ""    
    ce.surname_and_name.should == ", "    
  end    
end

describe TestTrait::MyHomePage do
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
  
  it "bit should act as a boolean" do
    page = TestTrait::MyHomePage.new
    page.bit.should == true
    page.toggle!
    page.bit.should == false
    page.not.should == true
    
    page.set!
    page.bit.should == true

    unless page.bit
      raise "should act as a true value"
    end
    page.unset!
    page.bit.should == false

    if !! page.bit # necessary!!!
      raise "should act as a false value"
    end

    if page.value 
      raise "should act as a false value"
    end
  end

  it "important should be converted to integer" do
    page = TestTrait::MyHomePage.new(important: 1)
    page.important.should       == 1
    page.plus(1).should         == 2
    page.minus(4).should        == -3
    (page.important + 5).should == 6
  end 

  it "important should be converted to integer returning nil" do
    page = TestTrait::MyHomePage.new(important: nil)
    page.important.should        == nil 
    page.plus(1).should          == nil
    page.minus(4).should         == nil
    (page.important + 5).should  == nil
  end

  it "important2 should be converted to integer" do
    page = TestTrait::MyHomePage.new(important2: 1)
    page.important2.should       == 1
    page.plus2(1).should         == 2
    page.minus2(4).should        == -3
    (page.important2 + 5).should == 6
  end 

  it "important2 should be converted to integer returning 0" do
    page = TestTrait::MyHomePage.new(important2: nil)
    page.important2.should        be_zero
    page.plus2(1).should          == 0
    page.minus2(4).should         == 0
    (page.important2 + 5).should  == 0
  end

  it "phrase should be converted to String" do
    page = TestTrait::MyHomePage.new(phrase: "hello")
    page.phrase.should           == "hello"
    page.upcase_phrase           == "HELLO"
    (page.upcase_phrase.concat ", WORLD").should == "HELLO, WORLD"
  end 

  it "phrase should returning empty string" do
    page = TestTrait::MyHomePage.new(phrase: nil)
    page.phrase.should           be_eql? ""
    page.upcase_phrase           == ""
    (page.upcase_phrase.concat ", WORLD").should == ", WORLD"
  end        
end  
  