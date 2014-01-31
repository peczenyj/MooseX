# MooseX

A postmodern object system for Ruby [![Build Status](https://travis-ci.org/peczenyj/MooseX.png)](https://travis-ci.org/peczenyj/MooseX)

```ruby
    require 'moosex'
    
    class Point
    	include MooseX
	
    	has :x , {
    		:is => :rw,      # read-write 
    		:isa => Integer, # should be Integer
    		:default => 0,   # default value is 0 (constant)
    	}

    	has :y , {
    		:is => :rw,
    		:isa => Integer,
    		:default => lambda { 0 }, # you should specify a lambda
    	}
	
    	def clear 
    		self.x= 0        # to run with type-check you must
    		self.y= 0        # use the setter instad @x=
    	end
    end

    class Foo
        include MooseX

        has :bar, {  
            :is => :rwp,      # read-write-private (private setter)
            :isa => Integer, 
            :required => true, # you should require in the constructor 
        }
    end

    class Baz
        include MooseX

        has :bam, {
            :is => :ro,         # read-only, you should specify in new only
            :isa => lambda {|x| # you should add your own validator
                raise 'x should be less than 100' if x > 100
            },
            :required => true,
            :predicate => true, # add has_bam? method, ask if the attribute is unset
            :clearer => true,   # add reset_bam! method, unset the attribute
        }

    end

    class Lol 
        include MooseX

        has [:a, :b], {     # define attributes a and b
            :is => :ro,     # with same set of properties
            :default => 0,      
        }

        has :c => {         # alternative syntax to be 
            :is => :ro,     # more similar to Moo/Moose    
            :default => 1,
            :predicate => :can_haz_c?,     # custom predicate
            :clearer => "desintegrate_c",  # force coerce to symbol
        }
    end    

    # now you have a generic constructor
    p1  = Point.new                       # x and y will be 0
    p2  = Point.new( :x => 5 )            # y will be 0
    p3  = Point.new( :x => 5, :y => 4)
    foo = Foo.new( :bar => 123 )          # without bar will raise exception
    baz = Baz.new( :bam => 99 )           # if bam > 100 will raise exception
```
    
## Installation

Add this line to your application's Gemfile:

    gem 'moosex'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install moosex

## Usage

MooseX is an extension of Ruby object system. The main goal of MooseX is to make Ruby Object Oriented programming easier, more consistent, and less tedious. With MooseX you can think more about what you want to do and less about the mechanics of OOP. It is a port of Moose/Moo from Perl to Ruby world.

## Contributing

1. Fork it ( http://github.com/peczenyj/MooseX/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
