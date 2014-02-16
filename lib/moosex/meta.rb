module MooseX

  class Meta
    attr_reader :attrs, :requires, :hooks, :plugins

    def initialize(old_meta=nil)
      @initialized = false
      @attrs    = {}
      @requires = []
      @roles    = []
      @plugins  = []

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
        @plugins  = old_meta.plugins.clone
      end
    end

    def info
      @attrs.map{|attr_symbol, attr| {attr_symbol => attr.doc }}.reduce(:merge)
    end
    
    def init_roles(*args)
      @roles.each do|role| 
        role.call(*args)
      end  
    end

    def load_from(module_or_class)
      other_meta = module_or_class.__moosex__meta
      other_meta.attrs.each_pair do |key, value|
        @attrs[key] = value.clone
      end     
      @requires += other_meta.requires
      @plugins  += other_meta.plugins
    end
    
    def load_from_klass(klass)
      other_meta = klass.__moosex__meta

      other_meta.hooks.each_pair do |hook, data|
        data.each_pair do |m, b|
          @hooks[hook][m] += b.clone
        end
      end
      @plugins  += other_meta.plugins
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
      @attrs.each_pair do |symbol, attr| 
        attr.init(object, args)
      end  

      MooseX.warn "unused attributes #{args} for #{object.class}", caller unless args.empty?  

      @requires.each do |method|
        unless object.respond_to? method
          raise RequiredMethodNotFoundError,
            "you must implement method '#{method}' in #{object.class}: required"
        end 
      end
    end

    def init_klass(klass)
      @hooks.values.map {|h| h.keys }.flatten.uniq.map do |method_name|
        begin
          [ klass.instance_method(method_name), method_name ]
        rescue => e
          MooseX.warn "Unable to apply hooks (after/before/around) in #{klass}::#{method_name} : #{e}" # if $MOOSEX_DEBUG
          nil
        end
      end.select do |value| 
        !value.nil?
      end.reduce({}) do |hash, tuple|
        method, method_name = tuple

        hash[method_name] = __moosex__init_hooks(method_name, method)

        hash
      end
    end

    def verify_requires_for(x)
      @requires.each do |method|
        unless x.public_instance_methods.include? method
          MooseX.warn "you must implement method '#{method}' in #{x} #{x.class}: required"# if $MOOSEX_DEBUG
        end 
      end
    end

    def add_plugin(plugin)
      @plugins << plugin
    end

    private
    def __moosex__init_hooks(method_name, method)

      before = @hooks[:before][method_name]
      after  = @hooks[:after][method_name]
      around = @hooks[:around][method_name]

      original = ->(object, *args, &proc) do
        method.bind(object).call(*args, &proc)
      end 

      ->(*args, &proc) do
        before.each{|b| b.call(self,*args, &proc)}
        
        result = around.inject(original) do |lambda1, lambda2|
          lambda2.curry[lambda1] 
        end.call(self, *args, &proc)

        after.each{|b| b.call(self,*args, &proc)}
        
        result
      end
    end

  end 
end   