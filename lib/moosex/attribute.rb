require 'moosex/types'
require 'moosex/attribute/modifiers'

module MooseX
  class Attribute
    include MooseX::Types

    attr_reader :attr_symbol, :methods, :attribute_map

    def is       ; @attribute_map[:is] ; end
    def writter  ; @attribute_map[:writter] ; end
    def reader   ; @attribute_map[:reader] ; end
    def override ; @attribute_map[:override] ; end
    def doc      ; @attribute_map[:doc] ; end
    def default  ; @attribute_map[:default] ; end

    @@LIST_OF_PARAMETERS = [ 
      [:is,        MooseX::AttributeModifiers::Is       ],
      [:isa,       MooseX::AttributeModifiers::Isa      ],
      [:default,   MooseX::AttributeModifiers::Default  ],
      [:required,  MooseX::AttributeModifiers::Required ],
      [:predicate, MooseX::AttributeModifiers::Predicate],
      [:clearer,   MooseX::AttributeModifiers::Clearer  ],
      [:traits,    MooseX::AttributeModifiers::Traits   ],        
      [:handles,   MooseX::AttributeModifiers::Handles  ], 
      [:lazy,      MooseX::AttributeModifiers::Lazy     ], 
      [:reader,    MooseX::AttributeModifiers::Reader   ], 
      [:writter,   MooseX::AttributeModifiers::Writter  ], 
      [:builder,   MooseX::AttributeModifiers::Builder  ], 
      [:init_arg,  MooseX::AttributeModifiers::Init_arg ], 
      [:trigger,   MooseX::AttributeModifiers::Trigger  ], 
      [:coerce,    MooseX::AttributeModifiers::Coerce   ], 
      [:weak,      MooseX::AttributeModifiers::Weak     ], 
      [:doc,       MooseX::AttributeModifiers::Doc      ], 
      [:override,  MooseX::AttributeModifiers::Override ],
    ]

    def initialize(attr_symbol, options ,klass)
      @attr_symbol   = attr_symbol
      @attribute_map = {}

      init_internal_modifiers(options.clone, klass.__moosex__meta.plugins, klass)
    end

    def init_internal_modifiers(options, plugins, klass)
      @@LIST_OF_PARAMETERS.each do |tuple|
        parameter, k = tuple 
        @attribute_map[parameter] = k.new(self).process(options, @attr_symbol)
      end
      
      generate_all_methods
      
      plugins.sort.uniq.each do |key|
        begin
          k = MooseX::AttributeModifiers::ThirdParty.const_get(key.to_s.capitalize.to_sym)          
          @attribute_map[key.to_sym] = k.new(self).process(options)
        rescue NameError => e
          next
        rescue => e
          raise "Unexpected Error in #{klass} #{key} #{@attr_symbol}: #{e}"  
        end  
      end

      MooseX.warn "Unused attributes #{options} for attribute #{@attr_symbol} @ #{klass} #{klass.class}",caller() if ! options.empty?  
    end

    def generate_all_methods
      @methods       = {}

      if @attribute_map[:reader] 
        @methods[@attribute_map[:reader]] = generate_reader
      end
      
      if @attribute_map[:writter] 
        @methods[@attribute_map[:writter]] = generate_writter
      end

      inst_variable_name = "@#{@attr_symbol}".to_sym
      if @attribute_map[:predicate]
        @methods[@attribute_map[:predicate]] = ->(this) do
          this.instance_variable_defined? inst_variable_name
        end
      end

      if @attribute_map[:clearer]
        @methods[@attribute_map[:clearer]] = ->(this) do
          if this.instance_variable_defined? inst_variable_name
            this.remove_instance_variable inst_variable_name
          end
        end
      end

      generate_handles @attr_symbol
    end

    def generate_handles(attr_symbol)

      delegator = ->(this) { this.__send__(attr_symbol) }

      @attribute_map[:handles].each_pair do | method, target_method |
        if target_method.is_a? Array
          original_method, currying = target_method

          @methods[method] = generate_handles_with_currying(delegator, original_method, currying)         
        else  
          @methods[method] = Proc.new do |this, *args, &proc|
            delegator.call(this).__send__(target_method, *args, &proc)
          end
        end 
      end  
    end    

    def generate_handles_with_currying(delegator, original_method, currying)
      Proc.new do |this, *args, &proc|

        a1 = [ currying ]

        if currying.is_a?Proc
          a1 = currying[]
        elsif currying.is_a? Array
          a1 = currying.map{|c| (c.is_a?(Proc)) ? c[] : c }
        end

        delegator.call(this).__send__(original_method, *a1, *args, &proc)
      end
    end   
    
    def init(object, args)
      value  = nil
      value_from_default = false
      
      if args.has_key? @attribute_map[:init_arg]
        value = args.delete(@attribute_map[:init_arg])
      elsif @attribute_map[:default]
        value = @attribute_map[:default].call
        value_from_default = true
      elsif @attribute_map[:required]
        raise InvalidAttributeError, "attr \"#{@attr_symbol}\" is required"
      else
        return
      end

      value = @attribute_map[:coerce].call(value)   
      begin
        @attribute_map[:isa].call( value )
      rescue MooseX::Types::TypeCheckError => e
        raise MooseX::Types::TypeCheckError, "isa check for field #{attr_symbol}: #{e}"
      end
      unless value_from_default
        @attribute_map[:trigger].call(object, value)
      end
      value = @attribute_map[:traits].call(value)
      inst_variable_name = "@#{@attr_symbol}".to_sym
      object.instance_variable_set inst_variable_name, value
    end

    private
    def generate_reader
      inst_variable_name = "@#{@attr_symbol}".to_sym
      
      builder    = @attribute_map[:builder]
      before_get = ->(object) { }

      if @attribute_map[:lazy]
        type_check = protect_isa(@attribute_map[:isa], "isa check for #{inst_variable_name} from builder")
        coerce     = @attribute_map[:coerce]
        trigger    = @attribute_map[:trigger]
        traits     = @attribute_map[:traits]
        before_get = ->(object) do
          return if object.instance_variable_defined? inst_variable_name

          value = builder.call(object)
          value = coerce.call(value)
          type_check.call( value )
          
          trigger.call(object, value)
          value = traits.call(value)
          object.instance_variable_set(inst_variable_name, value)         
        end
      end

      ->(this) do 
        before_get.call(this)
        this.instance_variable_get inst_variable_name 
      end
    end

    def protect_isa(type_check, message)
      ->(value) do
        begin
          type_check.call( value )
        rescue MooseX::Types::TypeCheckError => e
          raise MooseX::Types::TypeCheckError, "#{message}: #{e}"
        end
      end 
    end
    
    def generate_writter
      writter_name       = @attribute_map[:writter]
      inst_variable_name = "@#{@attr_symbol}".to_sym
      coerce             = @attribute_map[:coerce]
      type_check         = protect_isa(@attribute_map[:isa], "isa check for #{writter_name}")
      trigger            = @attribute_map[:trigger]
      traits             = @attribute_map[:traits]
      ->(this, value) do 
        value = coerce.call(value)
        type_check.call( value )
        trigger.call(this,value)
        value = traits.call(value)
        this.instance_variable_set inst_variable_name, value
      end
    end     
  end
end