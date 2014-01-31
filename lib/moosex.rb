# Module MooseX
# A postmodern object system for Ruby
#
# MooseX is an extension of Ruby object system. The main goal of MooseX is to make Ruby Object Oriented programming easier, more consistent, and less tedious. With MooseX you can think more about what you want to do and less about the mechanics of OOP. It is a port of Moose/Moo from Perl to Ruby world.

require "moosex/version"

module MooseX
	
	def self.included(o)
			
		o.extend(MooseX::Core)
			
		o.class_exec do 
			meta = MooseX::Meta.new

			define_singleton_method(:__meta) { meta }
		end

		def initialize(args={})

			self.class.__meta().init(self, args)

		end
					
	end
	
	module Core
	
		def has(attr_name, attr_options = {})
			if attr_name.is_a? Array 
				attr_name.each do |attr| 
					has(attr, attr_options) 
				end
			elsif attr_name.is_a? Hash 
				attr_name.each_pair do |attr, options |
					has(attr, options)
				end
			else

				attr = MooseX::Attribute.new(attr_name, attr_options)

				g = attr.generate_getter
				
	    		define_method attr_name, &g
	 
	 			s = attr.generate_setter
	 		
	 			if attr_options[:is].eql? :rw 
				
					define_method "#{attr_name}=", &s
				
				elsif attr_options[:is].eql? :rwp

					define_method "#{attr_name}=", &s
					
					private "#{attr_name}="

				end

				__meta.add(attr)
			end
		end
	end	
	
	class Attribute

		def initialize(a, o)
			@attr_symbol = a
			@options     = o
		end
		
		def init(object, args)
			setter = @attr_symbol.to_s.concat("=").to_sym
			value  = nil
 
			if args.has_key? @attr_symbol
				value = args[ @attr_symbol ]
			elsif @options[:required]
				raise "attr \"#{@attr_symbol}\" is required"
			else
				value = (@options[:default].is_a? Proc) ? @options[:default].call : @options[:default]
			end
 
 			if @options[:is].eql? :ro

 				# TODO: remove redundancy

				inst_variable_name = "@#{@attr_symbol}".to_sym
				type_check = generate_type_check
				type_check.call(value)
				object.instance_variable_set inst_variable_name, value
			
			else

				object.send( setter, value )
				
			end	
		end
		
		def generate_getter
			inst_variable_name = "@#{@attr_symbol}".to_sym
			Proc.new { instance_variable_get inst_variable_name }
		end
		
		def generate_setter
			inst_variable_name = "@#{@attr_symbol}".to_sym
			type_check = generate_type_check
			Proc.new  do |value| 
				type_check.call(value)
				instance_variable_set inst_variable_name, value
			end
		end
		
		def generate_type_check
			if @options.has_key? :isa
				isa = @options[:isa]

				return isa if isa.is_a? Proc

				return lambda do |new_value|
					raise "isa check for \"#{@attr_symbol}\" failed: lol is not #{isa}!" unless new_value.is_a? isa
				end	 
			end
 
			lambda { |new_value| }
		end			
	end
	
	class Meta
		def initialize
			@attrs = []
		end
		
		def add(attr)
			@attrs << attr
		end
		
		def init(object, args)
			@attrs.each{ |attr| attr.init(object, args) }
		end
	end	
end