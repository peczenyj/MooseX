# Moosex

A postmodern object system for Ruby

```ruby
    class Point
    	include MooseX
	
    	has :x , {
    		:is => :rw,
    		:isa => Integer,
    		:default => 0,
    	}

    	has :y , {
    		:is => :rw,
    		:isa => Integer,
    		:default => lambda { 0 },
    	}
	
    	def clear 
    		self.x= 0
    		self.y= 0
    	end
    end
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
