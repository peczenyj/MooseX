module MooseX
    class Attribute
    include MooseX::Types

    attr_reader :attr_symbol, :is, :reader, :writter, :lazy, :builder, :methods, :override
    DEFAULTS= { 
      is: :rw,
      weak: false,
      lazy: false,
      clearer: false,
      required: false, 
      predicate: false,
      isa: isAny,
      handles: {},
      trigger: lambda {|object,value|},  # TODO: implement
      coerce: lambda {|object| object},  # TODO: implement
      doc: nil,
      override: false,
    }

    REQUIRED = []

    VALIDATE = {
      is: lambda do |is, field_name| 
        unless [:rw, :rwp, :ro, :lazy, :private].include?(is)
          raise InvalidAttributeError, "invalid value for field '#{field_name}' is '#{is}', must be one of :private, :rw, :rwp, :ro or :lazy"  
        end
      end,
    };

    COERCE = {
      is: lambda do |is, field_name| 
        is.to_sym 
      end,
      isa: lambda do |isa, field_name| 
        isType(isa) 
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
          raise InvalidAttributeError, "cannot coerce field predicate to a symbol for #{field_name}: #{e}"
        end
      end,
      clearer: lambda do|clearer, field_name| 
        if ! clearer
          return false
        elsif clearer.is_a? TrueClass
          return "clear_#{field_name}!".to_sym
        end
    
        begin
          clearer.to_sym
        rescue => e
          # create a nested exception here
          raise InvalidAttributeError, "cannot coerce field clearer to a symbol for #{field_name}: #{e}"
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
      weak: lambda do |weak, field_name|
        !! weak
      end,
      doc: lambda do |doc, field_name|
        doc.to_s
      end,
      override: lambda do |override, field_name|
        !! override
      end,
    };

    def initialize(a, o ,x)
      #o ||= {}
      # todo extract this to a framework, see issue #21 on facebook
      o = DEFAULTS.merge({
        reader: a,
        writter: a.to_s.concat("=").to_sym,
        builder: "build_#{a}".to_sym,
        init_arg: a,
      }).merge(o)

      REQUIRED.each { |field| 
        unless o.has_key?(field)
          raise InvalidAttributeError, "field #{field} is required for Attribute #{a}" 
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

      if o[:is].eql? :ro  
        o[:writter] = nil
      elsif o[:is].eql? :lazy
        o[:lazy] = true
        o[:writter] = nil
      end

      unless o[:lazy]
        o[:builder] = nil
      end

      if o[:weak]
        old_coerce = o[:coerce]
        o[:coerce] = lambda do |value|
          WeakRef.new old_coerce.call(value)
        end
      end

      @attr_symbol   = a
      @is            = o.delete(:is)
      @isa           = o.delete(:isa)
      @default       = o.delete(:default)
      @required      = o.delete(:required) 
      @predicate     = o.delete(:predicate)
      @clearer       = o.delete(:clearer)
      @handles       = o.delete(:handles)
      @lazy          = o.delete(:lazy)
      @reader        = o.delete(:reader)
      @writter       = o.delete(:writter)
      @builder       = o.delete(:builder)
      @init_arg      = o.delete(:init_arg)
      @trigger       = o.delete(:trigger)
      @coerce        = o.delete(:coerce)
      @weak          = o.delete(:weak)
      @documentation = o.delete(:doc)
      @override      = o.delete(:override)
      @methods       = {}

      MooseX.warn "Unused attributes #{o} for attribute #{a} @ #{x} #{x.class}",caller() if ! o.empty?  

      if @reader 
        @methods[@reader] = generate_reader
      end
      
      if @writter 
        @methods[@writter] = generate_writter
      end
      inst_variable_name = "@#{@attr_symbol}".to_sym
      if @predicate
        @methods[@predicate] = Proc.new do
          instance_variable_defined? inst_variable_name
        end
      end

      if @clearer
        @methods[@clearer] = Proc.new do
          if instance_variable_defined? inst_variable_name
            remove_instance_variable inst_variable_name
          end
        end
      end
      
      attr_symbol = @attr_symbol
      @handles.each_pair do | method, target_method |
        if target_method.is_a? Array
          original, currying = target_method

          @methods[method] = Proc.new do |*args, &proc|
          
            a1 = [ currying ]
          
            if currying.is_a?Proc
              a1 = currying.call()
            elsif currying.is_a? Array
              a1 = currying.map{|c| (c.is_a?(Proc)) ? c.call : c }
            end
          
            self.send(attr_symbol).send(original, *a1, *args, &proc)
          end         
        else  
          @methods[method] = Proc.new do |*args, &proc|
            self.send(attr_symbol).send(target_method, *args, &proc)
          end
        end 
      end     
    end
    
    def init(object, args)
      value  = nil
      value_from_default = false
      
      if args.has_key? @init_arg
        value = args.delete(@init_arg)
      elsif @default
        value = @default.call
        value_from_default = true
      elsif @required
        raise InvalidAttributeError, "attr \"#{@attr_symbol}\" is required"
      else
        return
      end

      value = @coerce.call(value)   
      begin
        @isa.call( value )
      rescue MooseX::Types::TypeCheckError => e
        raise MooseX::Types::TypeCheckError, "isa check for field #{attr_symbol}: #{e}"
      end
      unless value_from_default
        @trigger.call(object, value)
      end
      inst_variable_name = "@#{@attr_symbol}".to_sym
      object.instance_variable_set inst_variable_name, value
    end

    private
    def generate_reader
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
          begin
            type_check.call( value )
          rescue MooseX::Types::TypeCheckError => e
            raise MooseX::Types::TypeCheckError, "isa check for #{inst_variable_name} from builder: #{e}"
          end

          trigger.call(object, value)
          object.instance_variable_set(inst_variable_name, value)         
        end
      end

      Proc.new do 
        before_get.call(self)
        instance_variable_get inst_variable_name 
      end
    end
    
    def generate_writter
      writter_name       = @writter
      inst_variable_name = "@#{@attr_symbol}".to_sym
      coerce     = @coerce
      type_check = @isa
      trigger    = @trigger
      Proc.new  do |value| 
        value = coerce.call(value)
        begin
          type_check.call( value )
        rescue MooseX::Types::TypeCheckError => e
          raise MooseX::Types::TypeCheckError, "isa check for #{writter_name}: #{e}"
        end
        trigger.call(self,value)
        instance_variable_set inst_variable_name, value
      end
    end 
  end
end