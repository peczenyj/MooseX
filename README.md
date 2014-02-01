# MooseX

A postmodern object system for Ruby [![Build Status](https://travis-ci.org/peczenyj/MooseX.png)](https://travis-ci.org/peczenyj/MooseX)

THIS MODULE IS EXPERIMENTAL YET! BE CAREFUL!

Talk is cheap. Show me the code!

```ruby
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
    self.x= 0    # to run with type-check you must
    self.y= 0    # use the setter instad @x=
  end
end

class Foo
    include MooseX

    has bar: {  
        is: :rwp,            # read-write-private (private setter) 
        required: true,      # you should require in the constructor 
    }
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
        clearer: true,       # add reset_boom! method, unset the attribute
  }
end

class Lol 
    include MooseX

    has [:a, :b], {          # define attributes a and b
        is: :ro,             # with same set of properties
        default: 0,      
    }

    has c: {                 # alternative syntax to be 
        is: :ro,             # more similar to Moo/Moose    
        default: 1,
        predicate: :can_haz_c?,     # custom predicate
        clearer: "desintegrate_c",  # force coerce to symbol
    }

  has [:d, :e] => {
    is: "ro",                # can coerce from strings
    default: 2,   
  }    
end    

class Proxy
  include MooseX

  has target: {
    is:  :ro,
    default: lambda { Target.new }, # default, new instace of Target
    handles: {                      # handles is for delegation,
      my_method_x: :method_x,       # inject methods with new names 
      my_method_y: :method_y,       # old => obj.target.method_x
    },                              # now => obj.my_method_x
  }
end

class Target 
  def method_x; 1024; end             # works with simple methods
  def method_y(a,b,c); a + b + c; end # or methods with arguments
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

# now you have a generic constructor
p1  = Point.new                       # x and y will be 0
p2  = Point.new( x:  5 )              # y will be 0
p3  = Point.new( x:  5, y: 4)
foo = Foo.new( bar: 123 )             # without bar will raise exception
baz = Baz.new( bam: 99 )              # if bam > 100 will raise exception
Proxy.new.my_method_x                 # will call method_x in target, return 1024
```
    
## Installation

Add this line to your application's Gemfile:

    gem 'moosex'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install moosex

You need ruby 2.0.x or superior.

## Description

MooseX is an extension of Ruby object system. The main goal of MooseX is to make Ruby Object Oriented programming easier, more consistent, and less tedious. With MooseX you can think more about what you want to do and less about the mechanics of OOP. It is a port of Moose/Moo from Perl to Ruby world.

Read more about Moose on http://moose.iinteractive.com/en/

## Motivation

It is fun

## Usage

When you incluse the MooseX module in your class you can declare your attributes. The module provides a new constructor for you, you should not define 'initialize' anymore.


```ruby
require 'moosex'

class Point
  include MooseX

  has x: {
    is: :rw,           # read-write (mandatory)
    isa: Integer,      # should be Integer
    default: 0,        # default value is 0 (constant)
    required: false,   # if true, will be required in the constructor
    predicate: false,  # if true, add has_x? method
    clearer: false,    # if true, add clear_x! method 
    handles: [ :to_s ],# used for method delegation  
  }
  ...
end
```

in this example we add the attribute x, with read-write acessors, a default value and a type check.

```ruby
p1 = Point.new          # x will be initialize with 0 (default)
p2 = Point.new(x: 50)   # initialize x in the constructur
p3 = Point.new(x: "50") # will raise exception
p1.x = "lol"            # will raise too
```

to use the type check feature you must use the writter method for the attribute.

### Advantages

instead
```ruby
class Foo
  attr_accessor :bar, :baz, :bam

  def initialize(bar=0, baz=0, bam=0)
    unless [bar, baz, bam].all? {|x| x.is_a? Integer }
      raise "you should use only Integers to build Foo"
    end
    @bar = bar
    @baz = baz
    @bam = bam
  end
end
```
you can
```ruby
class Foo
  include MooseX

  has [:bar, :baz, :bam], {
    is: :rw,
    isa: Integer,
    default: 0
  }
end
``` 
instead
```ruby
class Proxy
  def initialize(target)
    @target=target
  end

  def method_x(a,b,c)
    @target.method_x(a,b,c)
  end
  def method_y(a,b,c)
    @target.method_y(a,b,c)
  end 
end
```
you can
```ruby
class Proxy
  include MooseX

  has :target, {
    is: :ro,
    handles => [ :method_x, :method_y ]
  }
end
```
and much more

## Lazy Attributes

```ruby
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
    builder: lambda{ |object| 2 }
  }

  def build_something
    1024
  end

  private 
  def my_build_other_thing
    128
  end
end
```

## TODO

1. Support to lazy attributes [done]
2. Support to BUILD and BUILDARGS hook
3. Support to Roles ( it is a Module on Steroids )
4. Support to after/before/around 
5. Improve the typecheck system (we should specify: we need an array of positive integers)
6. Improve the exception and warning system
7. Profit!

## Limitations

Experimental module, be careful.

Now has limited support to subclassing.

## Contributing

1. Fork it ( http://github.com/peczenyj/MooseX/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
