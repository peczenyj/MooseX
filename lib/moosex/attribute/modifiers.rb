module MooseX
  module AttributeModifiers
    module ThirdParty
    end
    module AttrBaseModifier
      def process(options, attr_symbol)
        @attr_symbol = attr_symbol

        local_options = { 
          name => default 
        }.merge(options)
        
        options.delete(name)

        return nil unless local_options.has_key?(name)

        attr = local_options[name]      
        attr = coerce(attr,attr_symbol)
        validate(attr, attr_symbol)

        attr = update_options(options, name, attr)

        attr
      end

      def name; self.class.name.downcase.split("::").last.to_sym ; end
      def default; nil; end
      def coerce(x,f); x ; end
      def validate(x,f);  end
      def update_options(options, name, attr); attr; end      
    end

    module AttrCoerceToBoolean
      def coerce(x, f)
        !! x
      end
    end

    module AttrCoerceToSymbol
      def coerce(x, f)
        x.to_sym
      end  
    end

    module AttrCoerceMethodToLambda
      def coerce(x, field_name)
        unless x.is_a? Proc
          x_name = x.to_sym
          x = lambda do |object, *value|
            object.send(x_name,*value)
          end
        end

        x       
      end
    end

    module AttrCoerceToString
      def coerce(x, f)
        x.to_s
      end  
    end

    class Is 
      include AttrBaseModifier
      include AttrCoerceToSymbol
      def default; :rw ; end
      def validate(is, field_name) 
        unless [:rw, :rwp, :ro, :lazy, :private].include?(is)
          raise InvalidAttributeError, "invalid value for field '#{field_name}' is '#{is}', must be one of :private, :rw, :rwp, :ro or :lazy"  
        end
      end
      def update_options(options, name, attr)
        if attr == :lazy
          attr = :ro
          options[:lazy] = true
        end

        if attr == :ro
          options[:writter] = nil
        end

        attr
      end         
    end

    class Isa 
      include AttrBaseModifier
      def default; MooseX::Attribute.isAny ; end
      def coerce(isa, field_name); MooseX::Attribute.isType(isa); end
    end

    class Default
      include AttrBaseModifier
      def coerce(default, field_name)
        if default.is_a?(Proc) || default.nil?
          return default 
        end  
        return lambda { default }         
      end
    end

    class Required
      include AttrBaseModifier
      include AttrCoerceToBoolean
    end

    module AttrCoerceToMethodBasedOnFieldName
      def coerce(x, field_name) 
        if ! x
          return x
        elsif x.is_a? TrueClass
          return method_name(field_name)
        end
    
        begin
          x.to_sym
        rescue => e
          # create a nested exception here
          raise InvalidAttributeError, "cannot coerce field #{name} to a symbol for #{field_name}: #{e}"
        end
      end
    end

    class Predicate
      include AttrBaseModifier
      include AttrCoerceToMethodBasedOnFieldName

      def method_name(field_name); "has_#{field_name}?".to_sym ; end
    end       

    class Clearer
      include AttrBaseModifier
      include AttrCoerceToMethodBasedOnFieldName

      def method_name(field_name); "clear_#{field_name}!".to_sym ; end
    end

    class Handles
      include AttrBaseModifier
      def default; {} ; end

      def populate_handles(handles, field_name)
        array_of_handles = handles

        unless array_of_handles.is_a? Array
          array_of_handles = [ array_of_handles ]
        end

        handles = array_of_handles.map do |handle|

          if handle == BasicObject
            
            raise InvalidAttributeError, "ops, should not use BasicObject for handles in #{field_name}"
          
          elsif handle.is_a? Class

            handle = handle.public_instance_methods - handle.superclass.public_instance_methods
          
          elsif handle.is_a? Module
            
            handle = handle.public_instance_methods

          end
          
          handle

        end.flatten.reduce({}) do |hash, method_name|
          hash.merge({ method_name => method_name })
        end

        handles
      end

      def coerce(handles, field_name)

        unless handles.is_a? Hash 
          handles = populate_handles(handles, field_name)
        end

        handles.map do |key,value|
          if value.is_a? Hash
            raise "ops! Handle should accept only one map / currying" unless value.count == 1
            
            original, currying = value.shift
  
            { key.to_sym => [original.to_sym, currying] }
          else
            { key.to_sym => value.to_sym }
          end
        end.reduce({}) do |hash,e| 
          hash.merge(e)
        end
      end
    end

    class Lazy 
      include AttrBaseModifier
      include AttrCoerceToBoolean
    end

    class Reader
      include AttrBaseModifier
      include AttrCoerceToSymbol 
      def default
        @attr_symbol
      end
    end

    class Writter
      include AttrBaseModifier
      
      def default
        @attr_symbol.to_s.concat("=").to_sym
      end
      def coerce(writter, field_name)
        return writter if writter.nil?

        writter.to_sym
      end
    end

    class Builder
      include AttrBaseModifier
      include AttrCoerceMethodToLambda

      def default
        "build_#{@attr_symbol}".to_sym
      end
    end

    class Init_arg
      include AttrBaseModifier
      include AttrCoerceToSymbol

      def default
        @attr_symbol
      end
    end
      

    class Trigger
      include AttrBaseModifier
      include AttrCoerceMethodToLambda
      
      def default
        lambda{|object, value| }
      end
    end

    class Coerce 
      include AttrBaseModifier
      include AttrCoerceMethodToLambda

      def default
        lambda {|object| object}
      end

      def update_options(options, name, attr)
        if options[:weak]
          old_coerce = attr
          attr = lambda do |value|
            WeakRef.new old_coerce.call(value)
          end
        end

        attr
      end
    end

    class Weak
      include AttrBaseModifier
      include AttrCoerceToBoolean
    end

    class Doc
      include AttrBaseModifier
      include AttrCoerceToString
    end

    class Override
      include AttrBaseModifier
      include AttrCoerceToBoolean
    end
  end
end