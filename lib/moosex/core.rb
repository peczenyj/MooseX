module MooseX
    module Core
    def on_init(&block)
      __moosex__meta.add_role(block)
    end
        
    def after(*methods_name, &block)
      __moosex__add_hooks(:after, methods_name, block, caller()) 
    end

    def before(*methods_name, &block)
      __moosex__add_hooks(:before, methods_name, block, caller()) 
    end

    def around(*methods_name, &block)
      __moosex__add_hooks(:around, methods_name, block, caller())
    end

    def requires(*methods)
      methods.each do |method_name|
        __moosex__meta.add_requires(method_name)
      end 
    end

    def has(attr_name, attr_options = {})
      if attr_name.is_a? Array
        attr_name.each do |attr| 
          __moosex__has(attr, attr_options) 
        end
      elsif attr_name.is_a? Hash 
        attr_name.each_pair do |attr, options |
          has(attr, options)
        end
      else
        __moosex__has(attr_name, attr_options)
      end
    end

    private
    def __moosex__add_hooks(hook, methods_name, block, c)
      methods_name.each do |method_name|  
        begin
          __moosex__try_to_add_hook_now(hook, method_name, block)
        rescue => e
          MooseX.warn "unable to apply hook #{hook} in #{method_name} @ #{self}: #{e}", c if self.is_a?(Class) 
          __moosex__meta.add_hook(hook, method_name, block)
        end
      end
    end

    def __moosex__try_to_add_hook_now(hook, method_name, block)
      case hook 
      when :before 
        __moosex__try_to_add_before_now(method_name, block)
      when :after
        __moosex__try_to_add_after_now(method_name, block)
      when :around
        __moosex__try_to_add_around_now(method_name, block)
      end  
    end

    def __moosex__try_to_add_before_now(method_name, block)
      method = instance_method method_name

      define_method method_name do |*args, &proc|
        block.call(self,*args, &proc)
        method.bind(self).call(*args, &proc)
      end      
    end

    def __moosex__try_to_add_after_now(method_name, block)
      method = instance_method method_name

      define_method method_name do |*args, &proc|
        result = method.bind(self).call(*args, &proc)
        block.call(self,*args,&proc)
        result
      end      
    end

    def __moosex__try_to_add_around_now(method_name, block)
      method = instance_method method_name

      code = Proc.new do | o, *a, &proc| 
        method.bind(o).call(*a,&proc) 
      end

      define_method method_name do |*args, &proc|
        block.call(code, self,*args, &proc)
      end      
    end

    def __moosex__has(attr_name, attr_options)
      attr = MooseX::Attribute.new(attr_name, attr_options, self)

      __moosex__meta.add(attr)

      __moosex__create_methods(attr)
    end

    def __moosex__create_methods(attr)
      attr.methods.each_pair do |method, proc|
        define_method method, &proc
      end

      if attr.is.eql?(:rwp) 
        private attr.writter
      elsif attr.is.eql?(:private)
        private attr.writter
        private attr.reader
      end
    end
  end
end