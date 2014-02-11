# MooseX

A postmodern object DSL for Ruby [![Build Status](https://travis-ci.org/peczenyj/MooseX.png)](https://travis-ci.org/peczenyj/MooseX) [![Gem Version](https://badge.fury.io/rb/moosex.png)](http://badge.fury.io/rb/moosex) [![Code Climate](https://codeclimate.com/github/peczenyj/MooseX.png)](https://codeclimate.com/github/peczenyj/MooseX) [![Dependency Status](https://gemnasium.com/peczenyj/MooseX.png)](https://gemnasium.com/peczenyj/MooseX) [![Coverage Status](https://coveralls.io/repos/peczenyj/MooseX/badge.png)](https://coveralls.io/r/peczenyj/MooseX)  [![githalytics.com alpha](https://cruel-carlota.pagodabox.com/f51f40f92298589b598a55bc753977f9 "githalytics.com")](http://githalytics.com/peczenyj/MooseX)
## Introduction

This is another DSL for object creation, aspects, method delegation and much more. It is based on Perl Moose and Moo, two important modules who add a better way of Object Orientation development (and I enjoy A LOT). Using a declarative style, using Moose/Moo you can create attributes, methods, the entire constructor and much more. But I can't find something similar in Ruby world, so I decide port a small subset of Moose to create a powerfull DSL for object construction.

Of course, there is few similar projects in ruby like 

- [Virtus](https://github.com/solnic/virtus)
- [Active Record Validations](http://edgeguides.rubyonrails.org/active_record_validations.html)

But the objetive of MooseX is different: this is a toolbox to create Classes based on DSL, with unique features like

- method delegation ( see 'handles')
- lazy attributes
- roles
- parameterized roles
- composable type check
- events

and much more.

This rubygem is based on this modules:

- [Perl Moose](http://search.cpan.org/~ether/Moose-2.1204/lib/Moose.pm)
- [Perl Moo](http://search.cpan.org/~ether/Moose-2.1204/lib/Moose.pm)
- [MooX::Types::MooseLike::Base](http://search.cpan.org/~mateu/MooX-Types-MooseLike-0.25/lib/MooX/Types/MooseLike/Base.pm)
- [MooseX::Event](http://search.cpan.org/~winter/MooseX-Event-v0.2.0/lib/MooseX/Event.pm)
- [MooseX::Role::Parameterized](http://search.cpan.org/~sartak/MooseX-Role-Parameterized-1.02/lib/MooseX/Role/Parameterized/Tutorial.pod)

See also:

- [Joose](https://code.google.com/p/joose-js/), a javascript port of Moose.
- [Perl 6](http://en.wikipedia.org/wiki/Perl_6#Object-oriented_programming) Perl 6 OO programming style.

Why MooseX? Because the namespace MooseX/MooX is open to third-party projects/plugins/extensions. You can upgrade your Moo(se) class using other components if you want. And there is one gem called 'moose' :/

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

  def clear! 
    self.x= 0     # to run with type-check you must
    self.y= 0     # use the setter instad @x=
  end

  def to_s
    "Point[x=#{self.x}, y=#{self.y}]"
  end 
end 

# now you have a generic constructor
p1  = Point.new                       # x and y will be 0
p2  = Point.new( x:  5 )              # y will be 0
p3  = Point.new( x:  5, y: 4)
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

You just need include the MooseX module in your class and start to describe the attributes with our DSL. This module will inject one smart constructor, acessor and other necessary methods.

Instead the normal way of add accessors, constructor, validation, etc

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
you can do this:

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

## DSL: the 'has' method

The key of the DSL is the 'has' method injected in your class. You should use this method do describe your class and define the behavior like this:

```ruby
has :attribute_name, { hash of properties }
```

to describe one new attribute you shoud specify some properties inside a Hash. The only mandatory property is the ':is', to specify how we should create the acessors (if public or private).

The options for "has" are as follows:

### is => ro|rw|rwp|private|lazy

**Required**, may be :ro, :rw, :rwp, :private or :lazy.

"ro" specify a read-only attribute - generate only the reader method - you should specify the value in the constructor or using "default".

"rw" specify a read-write attribute - generate both reader and writter methods.

"rwp" specify a read-write private attribute. Similar to "rw" but the writter is a private method.

"private" will generate both reader and writter as private methods

"lazy" similar to "ro", but also sets "lazy" to true and "builder" to "build_#{attribute_name}".

### isa => Class|lambda

You can specify an optional type check for the attribute. Accepts a lambda, and it must raise one exception if the type check fails. If you provides a Class or Module, we will call the 'is_a?' method in the new value againt the Class/Module. We call the type check routine on the constructor and in each call of the writter method.

You can specify your own kind of type validation.
```ruby
    isa: lambda do |new_value|
      unless new_value.respond_to? :to_sym
        raise "bar should respond to to_sym method!"
      end
    end,
``` 

Important: if you access the attribute instance name using @attribute_name= you loose the type check feature. You need always set/get the attribute value using the acessors generated by MooseX.

### default => Constant|lambda

You can specify an optional default value to one attribute. If we don't specify in the constructor, we will initialize the attribute with this value. You also can specify one lambda to force object creation.

```ruby
  default: 0,
```
or
```ruby
  default: lambda{ MyObject.new },
```

### required => true|false

if true, the constructor will raise error if this attribute was not present.

```ruby
  required: true,
```

if this attribute has a default value, we will initialize with this value and no exception will be raised.

Optional.

### coerce => method name|lambda

You can try to coerce the attribute value by a lambda/method before the type check phase. For example you can do

```ruby
  coerce: lambda{ |new_value| new_value.to_i },
```

or just

```ruby
  coerce: :to_i,
```

to force a convertion to integer. Or flatten one array, convert to symbol, etc. Optional.

### handles => Array|Hash|Class|Module

One of the greatest features in MooseX: you can inject methods and delegate the method calling to the attribute. For example, instead do this:

```ruby
  def some_method(a,b,c)
    @attribute.some_method(a,b,c)
  end
```

you simply specify one or more methods to inject.
```ruby
  handles: [:some_method],
```
If you specify one Module or Class, we will handle all public instance methods defined in that Module or Class ( if Class, we will consider all methods except the methods declared in the superclass). The only limitation is BasicObject (forbidden).

If you need rename the method, you can specify a Hash:
```ruby
  handles: {
    my_method_1: :method1,
    my_method_2: :method2,
  },
```

Optional.
#### Currying

It is possible curry constant values declaring a pair/hash and set one or more constant values / lambdas

```ruby
  handles: {
    my_method_1: {
     method1: 1   
    }
  },
```

this will curry the constant 1 to the argument list. In other words:

```ruby
obj.target.method1(1,2,3) # OR
obj.my_method_1(2,3)
```

are equivalent. You can curry as many arguments as you can.

```ruby
  handles: {
    my_method_2: {
     method2: [1, lambda{ 2 } ]   
    }
  },
```

will generate
```ruby
obj.target.method1(1,2,3) # OR
obj.my_method_2(3)
```

are equivalent. if we find one lambda we will call on runtime.

Important: if you need do something more complex ( like manipulate the argument list, etc ) consider use the hook 'around'.

###### But how we can curry arrays?

Use Double arrays

```ruby
  handles: {
    my_method_1: {
     method1: [ [1,2,3] ]  
    }
  },
```
this will curry the array [1,2,3] to the argument list. In other words:

```ruby
obj.target.method1([1,2,3],2,3) # OR
obj.my_method_1(2,3)
```
are equivalent.

### trigger => method name|lambda

You can specify one lambda or method name to be executed in each writter ( if coerce and type check does not raise any exception ). The trigger will be called in each setter and in the constructor if we do not use the default value. Useful to add a logging operation or some complex validation.

```ruby
  trigger: lambda do |object, new_value| 
    object.logger.log "change the attribute value to #{new_value}"
  end
```
or
```ruby
has a: { is: :rw }
has b: {
  is: :rw,
  trigger: :verify_if_a_and_b_are_different,
  }
...
  def verify_if_a_and_b_are_different(new_value_of_b)
    if self.a.eql? new_value_of_b
      raise "a and b should be different!"
    end
  end
```

Optional.

### writter => true|method name

You can specify the name of the attribute acessor, default is "#{attribute_name}=" (if true).

### reader => true|method name

You can specify the name of the attribute acessor, default is "attribute_name" (if true).

### predicate => true|method name

Creates a method who returns a boolean value if the attribute is defined. If true, will create one public "has_#{attribute_name}?" method by default.

For example 
```ruby
class Foo
  include MooseX

  has x: {
    is: :rw,
    predicate: true,
  }
end

foo = Foo.new
foo.has_x?     # returns false
foo.x= 10
foo.has_x?     # returns true
```
Important: nil is different than undefined. If you do not initialize one attribute, you will receive one 'nil' if you try to fetch the value, but the state of this attribute is 'undefined'. If you set any value (even nil), the attribute will be considered 'defined' and the predicate will return true.

Optional.

### clearer => true| attribute name

Creates a method who will unset the attribute. If true, will create one public "clear_#{attribute_name}!" method by default. Unset in this case is not 'nil', we will remove the instance variable. For example:

```ruby
class Foo
  include MooseX

  has x: {
    is: :rw,
    predicate: true,
    clearer: true,
  }
end

foo = Foo.new
foo.has_x?     # returns false
foo.x= 10
foo.has_x?     # returns true
foo.clear_x!   # will unset the attribute x
foo.has_x?     # returns false
```
Optional.

### init_arg => "new attribute name"

You can rename the attribute name in the constructor. For example:

```ruby
class Foo
  include MooseX

  has secret: {
    is: :rw,
    writter: :x=,
    reader: :x,
    init_arg: :x,
  }
end

foo = Foo.new(x: 1)  # specify the value of secret in the constructor
foo.x                # return 1 
foo.x= 2             # will set 'secret' to 2
```

### lazy => true|false

Another great feature: lazy attributes. If you this to true, we will wait until the first reader accessor be called to create the object using the builder method, then store the value. For example:

```ruby
class Foo
  include MooseX

  has x: {
    is: :rw,
    lazy: :true,
    predicate: true,  # predicate and clearer are just
    clearer: true,    # to show a better example
  }

  def builder_x
    Some::Class.new
  end
end

foo = Foo.new  # normal...
foo.has_x?     # returns false
foo.x          # will call the builder_x method and store the value
foo.has_x?     # returns true
foo.x          # returns the stored value
foo.clear_x!   # will unset the attribute x
foo.has_x?     # returns false
foo.x          # will call the builder again and store the value
```
A lazy attribute needs a builder method or lambda. By default you should implement the "builder_#{attribute_name}" method. Using lazy you should initialize one attribute when you really need.

Optional.

### builder => method name|lambda

You can specify the builder name if the attribute is lazy, or you can specity one lambda. If true, the default name of the builder will be "builder_#{attribute_name}". This attribute will be ignored if the attribute is not lazy.

```ruby
class Foo
  include MooseX

  has x: {
    is: :rw,
    lazy: :true,
    builder: lambda{ |foo| Some::Class.new } # you can ignore foo, or use it!
  }
end
```
Optional.

### weak => true|false

If true, we will always coerce the value from default, constructor or writter to a WeakRef. Weak Reference class that allows a referenced object to be garbage-collected.

```ruby
class Foo
  include MooseX
  has x: { is: :rw, weak: true }
end

f = Foo.new(x: Object.new)

puts f.x.class # will be WeakRef
GC.start
puts f.x       # may raise exception (recycled) 
```

You should verify with `weakref_alive?` method to avoid exceptions.

## Hooks: after/before/around

Another great feature imported from Moose are the hooks after/before/around one method. You can run an arbitrary code, for example:

```ruby
class Point 
  include MooseX

  has [:x, :y ], { is: :rw, required: true }

  def clear!
    self.x = 0
    self.y = 0
  end
end

class Point3D < Point

  has z: { is: :rw, required: true }

  after :clear! do |object|
    object.z = 0
  end
end
```

instead redefine the 'clear!' method in the subclass, we just add a piece of code, a lambda, and it will be executed after the normal 'clear!' method.

Each after/before/around will **redefine** the original method in order. If you want override the method in some subclass, you will loose all hooks. The best way to preserve all hooks is using after/before/around to modify the behavior if possible. 

Roles and Hooks

If you try to add one role to a method who does not exists yet, this will be added in the next class. BE CAREFUL, THIS IS EXPERIMENTAL! PLEASE REPORT ANY BUG IF YOU FIND!!!

### after (method| ARRAY) => lambda 

The after hook should receive the name of the method as a Symbol and a lambda. This lambda will, in the argument list, one reference for the object (self) and the rest of the arguments. This will redefine the the original method, add the code to run after the method. The after does not affect the return value of the original method, if you need this, use the 'around' hook.

### before (method| ARRAY) => lambda

The before hook should receive the name of the method as a Symbol and a lambda. This lambda will, in the argument list, one reference for the object (self) and the rest of the arguments. This will redefine the the original method, add the code to run before the method.

A good example should be logging:

```ruby
class Point 
  include MooseX

  def my_method(x)
    # do something
  end

  before :my_method do |object, x|
    puts "#{Time.now} before my_method(#{x})"
  end
  after :my_method do |object, x|
    puts "#{Time.now} after my_method(#{x})"
  end
end
```

### around (method| ARRAY) => lambda

The around hook is agressive: it will substitute the original method for a lambda. This lambda will receive the original method as a lambda, a reference for the object and the argument list, you shuld call the method_lambda using object + arguments

```ruby
  around(:sum) do |method_lambda, object, a,b,c|
    c = 0
    result = method_lambda.call(object,a,b,c)
    result + 1
  end
```

it is useful to manipulate the return value or argument list, add a begin/rescue block, aditional validations, etc, if you need.

## MooseX::Types

MooseX has a built-in type system to be helpful in many circunstances. How many times you need check if some argument is_a? Something? Or it respond_to? :some_method ? Now it is over. If you include the **MooseX::Types** module in your MooseX class you can use:

### isAny

will accept any type. Useful to combine with other types.

```ruby
class Example
  include MooseX
  include MooseX::Types

  has x: { is: :rw, isa: isAny }
```

### isConstant

will verify using :=== if the value is equal to some contant

```ruby
  has x: { is: :rw, isa: isConstant(1) }
```

### isType, isInstanceOf and isConsumerOf

will verify the type using is_a? method. should receive a Class. isInstanceOf is an alias, to be used with Classes and isConsumerOf is for Modules.

```ruby
  has x: { is: :rw, isa: isConsumerOf(Enumerable) }
```

### hasMethods

will verify if the value respond_to? for one or more methods.

```ruby
  has x: { is: :rw, isa: hasMethods(:to_s) }
```
### isEnum

verify if the value is part of one enumeration of constants.

```ruby
  has x: { is: :rw, isa: isEnum(:black, :white, :red, :green, :yellow) }
```

### isMaybe(type)

verify if the value isa type or is nil. You can combine with other types.

```ruby
  has x: { is: :rw, isa: isMaybe(Integer) } # accepts 1,2,3... or nil
```

### isNot(type)

will revert the type check. Useful to combine with other types

```ruby
  has x: { 
    is: :rw,   # x will accept any values EXCEPT :black, :white...
    isa: isNot(isEnum(:black, :white, :red, :green, :yellow)) 
  }
```

### isArray(type)

Will verify if the value is an Array. Can receive one extra type, and we will verify each element inside the array againt this type, or Any if we not specify the type.

```ruby
  has x: { 
    is: :rw,  
    isa: isArray()    # will accept any array
  }
  has y: { 
    is: :rw,          # this is a more complex type
    isa: isArray(isArray(isMaybe(Integer))) 
  }  
```

### isHash(type=>type)

similar to isArray. if you do not specify a pair of types, it will check only if the value is_a? Hash. Otherwise we will verify each pair key/value.

```ruby
  has x: { 
    is: :rw,  
    isa: isHash()       # will accept any Hash
  }
  has y: { 
    is: :rw,            # this is a more complex type
    isa: isHash(Integer => isArray(isMaybe(Integer))) 
  }  
```

### isSet(type)

similar to isArray. the difference is: it will raise one exception if there are non unique elements in this array.

```ruby
  has x: { 
    is: :rw,  
    isa: isSet(Integer)  # will accept [1,2,3] but not [1,1,1]
  }
```

### isTuple(types)

similar to isArray, Tuples are Arrays with fixed size. We will verify the type of each element.

For example, to specify one tuple with three elements, the first is Integer, the second is a Symbol and the las should be a String or nil:

```ruby
  has x: { 
    is: :rw,  
    isa: isTuple(Integer, Symbol, isMaybe(String))       
  }
```

### isAllOf(types)

will combine all types and will fail if one of the condition fails.

```ruby
  has x: { 
    is: :rw,  
    isa: isAllOf(
        hasMethods(:foo, :bar),     # x should has foo and bar methods
        isConsumerOf(Enumerable),   # AND should be an Enumerable
        isNot(SomeForbiddenClass),  # AND and should not be an SomeForbiddenClass
      )
  }
```

### isAnyOf(types)

will combine all types and will fail if all of the condition fails.

```ruby
  has x: { 
    is: :rw,  
    isa: isAnyOf(
        hasMethods(:foo, :bar),   # x should has foo and bar methods 
        isEnum(1,2,3,4),          # OR be 1,2,3 or 4
        isHash(isAny => Integer)  # OR be an Hash of any type => Integers
      )
  }
```

## Roles

Roles are Modules with steroids. If you include the MooseX module in another module, this module became a "Role", capable of store attributes to be reuse in other MooseX classes. For example:

```ruby
require 'moosex'

module Eq
  include MooseX

  requires :equal

  def no_equal(other)
    ! self.equal(other)
  end 
end

module Valuable
  include MooseX

  has value: { is: :ro, required: true } 
end 

class Currency
  include Valuable.init(warnings: false) # default is true!
  include Eq  # default will warn about equal missing. 
              # alternative: include after equal definition!
              
  def equal(other)
    self.value == other.value
  end

  # include Eq # warning 'safe' include, after equal declaration
end

c1 = Currency.new( value: 12 )
c2 = Currency.new( value: 12 )

c1.equal(c2)          # true, they have the same value
c1.no_equal(c2)       # will return false
```

Roles can support has to describe attributes, and you can reuse code easily. 

### requires

You can also mark one or more methods as 'required'. When you do this, we will raise one exception if you try to create a new instance and the class does not implement it. It is a safe way to create interfaces or abstract classes. It uses respond_to? to verify.


## Parameterized Roles

Parameterized roles is a good way of reuse code based on roles. For example, to create one or more attributes in the class who includes our role, we just add the code to be executed in the on_init hook.

```ruby
module EasyCrud
  include MooseX
  
  on_init do |*attributes|
    attributes.each do | attr |
      has attr, { is: :rw, predicate: "has_attr_#{attr}_or_not?" }
    end
  end
end

class LogTest
  include EasyCrud.init(:a, :b)
   ...
```

when we call `init` with arguments, we will call all on_init blocks defined in the role. In this example we inject attributes 'a' and 'b' with reader/writter and a predicate based on the name ex: `has_attr_a_or_not?`

### composable parameterized roles

To combine one or more parameterized roles to another parameterized role you should do something like this:

```ruby
module Logabble2
  include MooseX
    
  on_init do |args|
    args[:klass] = self
    include Logabble.init(args)
  end  
end

module Logabble
  include MooseX
   
  on_init do | args |

    klass  = args[:klass]    || self  # <= THIS will guarantee you will
    methods = args[:methods] || []    #    modify the right class

    methods.each do |method|
      klass.around(method) do |original, object, *args|
        # add log around method
        # call original method
        # return
    ...
```

## BUILD

If you need run some code after the creation of the object (like some extra validation), you should implement the BUILD method.

```ruby
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

b1 = BuildExample.new(x: 1, y: 2) # will create the object 
b2 = BuildExample.new(x: 1, y: 1) # will raise the exception!
```

### BUILDARGS

If you need manupulate the constructor argument list, you should implement the method BUILDARGS. You MUST return one Hash of attribute_name => value.

```ruby
class BuildArgsExample2 
  include MooseX

  has [:x, :y], {
    is: :rw,
    required: true,
  }

  def BUILDARGS(x=4,y=8)
    args = {}
    args[:x] = x
    args[:y] = y
    
    args
  end
end

ex1 = BuildArgsExample2.new(1,2) # x == 1, y == 2
ex2 = BuildArgsExample2.new(1)   # x == 1, y == 8
ex3 = BuildArgsExample2.new()    # x == 4, y == 8
```

## EVENTS

MooseX has a built-in event system, and it should be useful if you want to avoid after/before hooks ( depends of what is your problem ).

```ruby
require 'moosex'
require 'moosex/event'

class Example
  include MooseX
  include MooseX::Event
  
  def ping
    self.emit(:pinged)
  end
end

e = Example.new

e.on(:pinged) do |object|
    puts "Ping!"
end

e.once(:pinged) do |object|
    puts "Ping Once!"
end
  
e.ping # will print two messages, "Ping!" and "Ping Once!"
e.ping # will print just "Ping!"  

e.remove_all_listeners(:pinged)

e.ping # will no longer print nothing

# you can use arguments
# consider you have one logger attribute in this example
listener = e.on(:error) do |obj, message|
    obj.logger.fatal("Error: #{message}")
end

e.emit(:error, "ops") # will log, as fatal, "Error: ops"

e.remove_listener( error: listener )

e.emit(:error, "...") # will no longer log nothing
```

If you want to restrict how many different events you can handle, you should overload the `has_events` method and return one array of valid events. If you want accept all, you should return nil (default).

For example, your method should emit many events, in many points, and you can add/remove listeners easily. And Much More!

### Events + Handles / Currying

Look this good example:

```ruby
require 'moosex'
require 'moosex/event'

class EventHandler
  include MooseX
  include MooseX::Event
  
  def has_events ; [ :pinged, :ponged ]; end    
end

class EventProcessor
  include MooseX
  
  has event_handler: {
    is: :ro,
    isa: EventHandler,
    default: lambda{ EventHandler.new }, # EventProcessor HAS ONE EventHandler
    handles: {                           # Now, lets start to delegate and currying:
      ping: { emit: :pinged },           # ping() is the same of event_handler.emit(:pinged)
      pong: { emit: :ponged },           # pong(x) is the same of event_handler.emit(:pinged,x)
      on_ping: { on: :pinged },          # 
      on_pong: { on: :ponged },          # same thing for on_ping / on_pong
    },
  }
end

ep = EventProcessor.new()

ep.on_ping do |obj| 
  puts "receive ping!"
end
  
ep.on_pong do |obj, message| 
  puts "receive pong with #{message}!"
end  

ep.ping   # will print "receive ping!"
ep.pong 1 # will print "receive pong with 1!"
```

Now, imagine what you can do with a parameterized role: we can create all handles based on event names!

## IMPORTANT

This module is experimental. I should test more and more to be possible consider this "production ready". If you find some issue/bug please add here: https://github.com/peczenyj/MooseX/issues

Until the first 0.1 version I can change anything without warning.

I am open to suggestions too.

## Mailing List

https://groups.google.com/d/forum/moosex-ruby-dev-list

## TODO

1. Support to Roles ( it is a Module on Steroids ) [done] 
2. Support to after/before/around [done]
3. Improve the typecheck system (we should specify: we need an array of positive integers) [done]
4. Improve the exception and warning system [in progress]
5. Profit!

## Limitations

Experimental module, be careful.

Now has limited support to subclassing.

## Contributing

1. Fork it ( http://github.com/peczenyj/MooseX/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## About the Author

[@pac_man](https://twitter.com/pac_man)

[about.me](http://about.me/peczenyj)
