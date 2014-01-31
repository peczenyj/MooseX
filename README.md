# Moosex

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

## Installation

Add this line to your application's Gemfile:

    gem 'moosex'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install moosex

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( http://github.com/<my-github-username>/moosex/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
