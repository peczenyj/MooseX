# Module MooseX
# A postmodern object system for Ruby
#
# MooseX is an extension of Ruby object system. The main goal of MooseX is to make Ruby Object Oriented programming easier, more consistent, and less tedious. With MooseX you can think more about what you want to do and less about the mechanics of OOP. It is a port of Moose/Moo from Perl to Ruby world.

require "moosex/version"

module MooseX
	
	def MooseX.included(c)
			
		c.extend(MooseX::Core)
			
		c.class_exec do 
			meta = MooseX::Meta.new

			define_singleton_method(:__meta) { meta }
		end

		def initialize(args={})

			self.class.__meta().init(self, args)

		end

		def c.inherited(subclass)
			subclass.class_exec do 
				old_meta = subclass.__meta

				meta = MooseX::Meta.new(old_meta.attrs)

				define_singleton_method(:__meta) { meta }
			end    		
   	end		
					
	end
	
	class Meta
		attr_reader :attrs
		def initialize(attrs=[])
			@attrs = attrs.map{|att| att.clone }
		end
		
		def add(attr)
			@attrs << attr
		end
		
		def init(object, args)
			@attrs.each{ |attr| attr.init(object, args) }
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
				
	    	define_method attr.reader, &g
	 
	 			s = attr.generate_setter
	 		
	 			case attr.is 
	 			when :rw 				
					define_method attr.writter, &s
				
				when :rwp
					define_method attr.writter, &s
					
					private attr.writter
				end

				__meta.add(attr)
			end
		end
	end	
	
	class Attribute

		attr_reader :attr_symbol, :is, :reader, :writter, :lazy, :builder
		DEFAULTS= { 
			lazy: false,
			clearer: false,
			required: false, 
			predicate: false,
			isa: lambda { |value| true },
			handles: {},
			trigger: lambda {|object,value|},  # TODO: implement
			coerce: lambda {|object| object},  # TODO: implement
		}

		REQUIRED = [ :is ]

		VALIDATE = {
			is: lambda do |is, field_name| 
				unless [:rw, :rwp, :ro, :lazy].include?(is)
					raise "invalid value for field '#{field_name}' is '#{is}', must be one of :rw, :rwp, :ro or :lazy"  
				end
			end,
		};

		COERCE = {
			is: lambda do |is, field_name| 
				is.to_sym 
			end,
			isa: lambda do |isa, field_name| 
				return isa if isa.is_a? Proc
				
				return lambda do |new_value| 
					unless new_value.is_a?(isa)
						raise "isa check for \"#{field_name}\" failed: is not instance of #{isa}!" 
					end 
				end	 
			end,
			default: lambda do |default, field_name|
				return default if default.is_a? Proc

				return lambda { default }		
			end,
			required: lambda do |required, field_name| 
				!!required 
			end,
			lazy: lambda do |lazy, field_name| 
				!!lazy 
			end,			
			predicate: lambda do |predicate, field_name| 
				if ! predicate
					return false
				elsif predicate.is_a? TrueClass
					return "has_#{field_name}?".to_sym
				end

				begin
					predicate.to_sym
				rescue => e
					# create a nested exception here
					raise "cannot coerce field predicate to a symbol for #{field_name}: #{e}"
				end
			end,
			clearer: lambda do|clearer, field_name| 
				if ! clearer
					return false
				elsif clearer.is_a? TrueClass
					return "reset_#{field_name}!".to_sym
				end
		
				begin
					clearer.to_sym
				rescue => e
					# create a nested exception here
					raise "cannot coerce field clearer to a symbol for #{field_name}: #{e}"
				end
			end,
			handles: lambda do |handles, field_name|
							
				unless handles.is_a? Hash 

					array_of_handles = handles

					unless array_of_handles.is_a? Array
						array_of_handles = [ array_of_handles ]
					end

					handles = array_of_handles.map do |handle|

						if handle == BasicObject
							
							raise "ops, should not use BasicObject for handles in #{field_name}"
						
						elsif handle.is_a? Class

							handle = handle.public_instance_methods - handle.superclass.public_instance_methods
						
						elsif handle.is_a? Module
							
							handle = handle.public_instance_methods

						end
						
						handle

					end.flatten.reduce({}) do |hash, method_name|
						hash.merge({ method_name => method_name })
					end
				end

				handles.map do |key,value|
					{ key.to_sym => value.to_sym }
				end.reduce({}) do |hash,e| 
					hash.merge(e)
				end
			end,
			reader: lambda do |reader, field_name|
				reader.to_sym
			end,
			writter: lambda do |writter, field_name|
				writter.to_sym
			end,
			builder: lambda do |builder, field_name|
				unless builder.is_a? Proc
					builder_method_name = builder.to_sym
					builder = lambda do |object|
						object.send(builder_method_name)
					end
				end

				builder
			end,
			init_arg: lambda do |init_arg, field_name|
				init_arg.to_sym
			end,
			trigger: lambda do |trigger, field_name|
				unless trigger.is_a? Proc
					trigger_method_name = trigger.to_sym
					trigger = lambda do |object, value|
						object.send(trigger_method_name,value)
					end
				end

				trigger				
			end,
			coerce: lambda do |coerce, field_name|
				unless coerce.is_a? Proc
					coerce_method_name = coerce.to_sym
					coerce = lambda do |object|
						object.send(coerce_method_name)
					end
				end

				coerce				
			end,
		};

		def initialize(a, o)
			# todo extract this to a framework, see issue #21 on facebook

			o = DEFAULTS.merge({
				reader: a,
				writter: a.to_s.concat("=").to_sym,
			  builder: "build_#{a}".to_sym,
			  init_arg: a,
			}).merge(o)

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

			if o[:is].eql? :lazy
				o[:lazy] = true
			end

			unless o[:lazy]
				o[:builder] = nil
			end	

			@attr_symbol = a
			@is          = o[:is]
			@isa         = o[:isa]
			@default     = o[:default]
			@required    = o[:required] 
			@predicate   = o[:predicate]
			@clearer     = o[:clearer]
			@handles     = o[:handles]
			@lazy        = o[:lazy]
			@reader      = o[:reader]
			@writter     = o[:writter]
			@builder     = o[:builder]
			@init_arg    = o[:init_arg]
			@trigger     = o[:trigger]
			@coerce      = o[:coerce]
		end
		
		def init(object, args)
			inst_variable_name = "@#{@attr_symbol}".to_sym
			
			value  = nil

			attr_symbol = @attr_symbol
			@handles.each_pair do | method, target_method |
				object.define_singleton_method method do |*args|
					self.send(attr_symbol).send(target_method, *args)
				end
			end

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

			value_from_default = false
			if args.has_key? @init_arg
				value = args[ @init_arg ]
			elsif @default
				value = @default.call
				value_from_default = true
			elsif @required
				raise "attr \"#{@attr_symbol}\" is required"
			else
				return
			end
 

			value = @coerce.call(value)

			@isa.call( value )
			unless value_from_default
				@trigger.call(object, value)
			end
			
			object.instance_variable_set inst_variable_name, value
			
		end
		
		def generate_getter
			inst_variable_name = "@#{@attr_symbol}".to_sym
			
			builder    = @builder
			before_get = lambda {|object|  }

			if @lazy
				type_check = @isa
				coerce     = @coerce
				trigger    = @trigger
				before_get = lambda do |object|
					return if object.instance_variable_defined? inst_variable_name

					value = builder.call(object)
					value = coerce.call(value)
					type_check.call(value)
					trigger.call(object, value)
					object.instance_variable_set(inst_variable_name, value)					
				end
			end

			Proc.new do 
				before_get.call(self)
				instance_variable_get inst_variable_name 
			end
		end
		
		def generate_setter
			inst_variable_name = "@#{@attr_symbol}".to_sym
			coerce     = @coerce
			type_check = @isa
			trigger    = @trigger
			Proc.new  do |value| 
				value = coerce.call(value)
				type_check.call(value)
				trigger.call(self,value)
				instance_variable_set inst_variable_name, value
			end
		end	
	end
end