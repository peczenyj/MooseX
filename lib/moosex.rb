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
				
	    		define_method attr.attr_symbol, &g
	 
	 			s = attr.generate_setter
	 		
	 			case attr.is 
	 			when :rw 				
					define_method "#{attr.attr_symbol}=", &s
				
				when :rwp
					define_method "#{attr.attr_symbol}=", &s
					
					private "#{attr.attr_symbol}="
				end

				__meta.add(attr)
			end
		end
	end	
	
	class Attribute

		attr_reader :attr_symbol, :is, :isa, :default, :required

		DEFAULTS= { 
			:clearer => false,
			:required => false, 
			:predicate => false,
			:isa => lambda { |x| true },
		}

		REQUIRED = [ :is ]

		VALIDATE = {
			:is => lambda do |is, field_name| 
				unless [:rw, :rwp, :ro, :lazy].include?(is)
					raise "invalid value for field '#{field_name}' is '#{is}', must be one of :rw, :rwp, :ro or :lazy"  
				end
			end,
		};

		COERCE = {
			:is  => lambda do |is, field_name| 
				is.to_sym 
			end,
			:isa => lambda do |isa, field_name| 
				return isa if isa.is_a? Proc
				
				return lambda do |new_value| 
					unless new_value.is_a?(isa)
						raise "isa check for \"#{field_name}\" failed: is not instance of #{isa}!" 
					end 
				end	 
			end,
			:default => lambda do |default, field_name|
				return default if default.is_a? Proc

				return lambda { default }		
			end,
			:required => lambda do |required, field_name| 
				!!required 
			end,
			:predicate => lambda do |predicate, field_name| 
				begin
					if ! predicate
						return false
					elsif predicate.is_a? TrueClass
						return "has_#{field_name}?".to_sym,
					end

					return predicate.to_sym
				rescue e
					# create a nested exception here
					raise "cannot coerce field predicate to a symbol for #{field_name}: #{e}"
				end
			end,
			:clearer => lambda do |clearer, field_name| 
				begin
					if ! clearer
						return false
					elsif clearer.is_a? TrueClass
						return "reset_#{field_name}!".to_sym,
					end

					return clearer.to_sym
				rescue e
					# create a nested exception here
					raise "cannot coerce field clearer to a symbol for #{field_name}: #{e}"
				end
			end,			
		};

		def initialize(a, o)
			# todo extract this to a framework, see issue #21 on facebook
			o = DEFAULTS.merge(o)

			REQUIRED.each { |field| 
				unless o.has_key?(field)
					raise "field #{field} is required for Attribute #{a}" 
				end
			}
			COERCE.each_pair do |field, coerce|
				if o.has_key? field
					o[field] = coerce.call(o[field], a)
				end
			end
			VALIDATE.each_pair do |field, validate|
				return if ! o.has_key? field

				validate.call(o[field], a)
			end	

			@attr_symbol = a
			@is          = o[:is]
			@isa         = o[:isa]
			@default     = o[:default]
			@required    = o[:required] 
			@predicate   = o[:predicate]
			@clearer     = o[:clearer]
		end
		
		def init(object, args)
			inst_variable_name = "@#{@attr_symbol}".to_sym
			
			setter = @attr_symbol.to_s.concat("=").to_sym
			value  = nil

			if @predicate
				object.define_singleton_method @predicate do
					instance_variable_defined? inst_variable_name
				end
			end

			if @clearer
				object.define_singleton_method @clearer do
					if instance_variable_defined? inst_variable_name
						remove_instance_variable inst_variable_name
					end
				end
			end

			if args.has_key? @attr_symbol
				value = args[ @attr_symbol ]
			elsif @required
				raise "attr \"#{@attr_symbol}\" is required"
			elsif @default
				value = @default.call
			else
				return
			end
 
 			if @is.eql? :ro

 				# TODO: remove redundancy

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

			return @isa
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