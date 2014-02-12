require 'moosex/types'
require 'moosex/attribute/modifiers'

module MooseX
    class Attribute
    include MooseX::Types

    attr_reader :attr_symbol, :is, :reader, :writter, :lazy, :builder, :methods, :override

    def initialize(attr_symbol, options ,klass)
      @attr_symbol   = attr_symbol
      
      init_internal_modifiers(options.clone, klass)

      generate_all_methods
    end
    
    def init_internal_modifiers(options, klass)
      @is            = Is.new.process(options, @attr_symbol)
      @isa           = Isa.new.process(options, @attr_symbol)
      @default       = Default.new.process(options, @attr_symbol)
      @required      = Required.new.process(options, @attr_symbol)
      @predicate     = Predicate.new.process(options, @attr_symbol)
      @clearer       = Clearer.new.process(options, @attr_symbol)
      @handles       = Handles.new.process(options, @attr_symbol)
      @lazy          = Lazy.new.process(options, @attr_symbol) 
      @reader        = Reader.new.process(options, @attr_symbol)
      @writter       = Writter.new.process(options, @attr_symbol)
      @builder       = Builder.new.process(options, @attr_symbol) # TODO: warn if has builder and it is not lazy
      @init_arg      = InitArg.new.process(options, @attr_symbol)
      @trigger       = Trigger.new.process(options, @attr_symbol)
      @coerce        = Coerce.new.process(options, @attr_symbol)
      @weak          = Weak.new.process(options, @attr_symbol)
      @documentation = Doc.new.process(options, @attr_symbol)
      @override      = Override.new.process(options, @attr_symbol)

      MooseX.warn "Unused attributes #{options} for attribute #{@attr_symbol} @ #{klass} #{klass.class}",caller() if ! options.empty?  
    end

    def generate_all_methods
      @methods       = {}

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

      inst_variable_name = "@#{@attr_symbol}".to_sym
      if @clearer
        @methods[@clearer] = Proc.new do
          if instance_variable_defined? inst_variable_name
            remove_instance_variable inst_variable_name
          end
        end
      end
      
      generate_handles @attr_symbol   
    end

    def generate_handles(attr_symbol)
      @handles.each_pair do | method, target_method |
        if target_method.is_a? Array
          original, currying = target_method

          @methods[method] = generate_handles_with_currying(attr_symbol,original, currying)         
        else  
          @methods[method] = Proc.new do |*args, &proc|
            self.send(attr_symbol).send(target_method, *args, &proc)
          end
        end 
      end  
    end    

    def generate_handles_with_currying(attr_symbol,original, currying)
      Proc.new do |*args, &proc|

        a1 = [ currying ]

        if currying.is_a?Proc
          a1 = currying.call()
        elsif currying.is_a? Array
          a1 = currying.map{|c| (c.is_a?(Proc)) ? c.call : c }
        end

        self.send(attr_symbol).send(original, *a1, *args, &proc)
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
        type_check = protect_isa(@isa, "isa check for #{inst_variable_name} from builder")
        coerce     = @coerce
        trigger    = @trigger
        before_get = lambda do |object|
          return if object.instance_variable_defined? inst_variable_name

          value = builder.call(object)
          value = coerce.call(value)
          type_check.call( value )
          
          trigger.call(object, value)
          object.instance_variable_set(inst_variable_name, value)         
        end
      end

      Proc.new do 
        before_get.call(self)
        instance_variable_get inst_variable_name 
      end
    end

    def protect_isa(type_check, message)
      lambda do |value|
        begin
          type_check.call( value )
        rescue MooseX::Types::TypeCheckError => e
          raise MooseX::Types::TypeCheckError, "#{message}: #{e}"
        end
      end 
    end
    
    def generate_writter
      writter_name       = @writter
      inst_variable_name = "@#{@attr_symbol}".to_sym
      coerce     = @coerce
      type_check = protect_isa(@isa, "isa check for #{writter_name}")
      trigger    = @trigger
      Proc.new  do |value| 
        value = coerce.call(value)
        type_check.call( value )
        trigger.call(self,value)
        instance_variable_set inst_variable_name, value
      end
    end 
  end
end