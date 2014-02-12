module MooseX

  class Meta
    attr_reader :attrs, :requires, :hooks, :roles

    def initialize(old_meta=nil)
      @initialized = false
      @attrs    = {}
      @requires = []
      @roles    = []

      @hooks = {
        before: Hash.new { |hash, key| hash[key] = [] },
        after:  Hash.new { |hash, key| hash[key] = [] },
        around: Hash.new { |hash, key| hash[key] = [] },
      }

      if old_meta
        old_meta.attrs.each_pair do |key, value|
          @attrs[key] = value.clone
        end
        @requires = old_meta.requires.clone
      end
    end

    def load_from(other_meta)
      other_meta.attrs.each_pair do |key, value|
        @attrs[key] = value.clone
      end     
      @requires += other_meta.requires
    end
    
    def load_hooks(other_meta)
      other_meta.hooks.each_pair do |hook, data|
        data.each_pair do |m, b|
          @hooks[hook][m] += b.clone
        end
      end
    end

    def add(attr)
      if @attrs.has_key?(attr.attr_symbol) && ! attr.override
        raise FatalError, "#{attr.attr_symbol} already exists, you should specify override: true" 
      end
      @attrs[attr.attr_symbol] = attr
    end

    def add_requires(method)
      @requires << method
    end

    def add_hook(hook, method, block)
      @hooks[hook][method] << block.clone
    end

    def add_role(block)
      @roles << block
    end

    def init(object, args)
      @attrs.each_pair{ |symbol, attr| attr.init(object, args) }

      MooseX.warn "unused attributes #{args} for #{object.class}", caller unless args.empty?  

      @requires.each do |method|
        unless object.respond_to? method
          raise RequiredMethodNotFoundError,
            "you must implement method '#{method}' in #{object.class}: required"
        end 
      end
    end

    def init_klass(klass)
      #return if @initialized

      @hooks.values.map {|h| h.keys }.flatten.uniq.each do |(method_name)|
        begin
          method = klass.instance_method method_name
        rescue => e
          MooseX.warn "Unable to apply hooks (after/before/around) in #{klass}::#{method_name} : #{e}" # if $MOOSEX_DEBUG
          next
        end        
        __moosex__init_hooks(klass,method_name, method)
      end
    end

    private
    def __moosex__init_hooks(klass, method_name, method)

      before = @hooks[:before][method_name]
      after  = @hooks[:after][method_name]
      around = @hooks[:around][method_name]

      klass.__moosex__meta_define_method(method_name) do |*args, &proc|
        before.each{|b| b.call(self,*args, &proc)}
        
        original = lambda do |object, *args, &proc| 
          method.bind(object).call(*args, &proc)
        end 

        result = around.inject(original) do |lambda1, lambda2|
          lambda2.curry[lambda1] 
        end.call(self, *args, &proc)

        after.each{|b| b.call(self,*args, &proc)}
        
        result
      end

    end

  end 
end   