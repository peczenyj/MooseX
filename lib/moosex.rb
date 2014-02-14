# Module MooseX
# A postmodern object DSL for Ruby
#
# Author::    Tiago Peczenyj  (mailto:tiago.peczenyj@gmail.com)
# Copyright:: Copyright (c) 2014 Tiago Peczenyj
# License::   MIT

require "moosex/version"
require "moosex/types"
require "moosex/exceptions"
require "moosex/meta"
require "moosex/core"
require "moosex/attribute"
require "moosex/traits"
require "weakref"

module MooseX
  @@ALIAS           = nil
  @@MOOSEX_WARNINGS = true
  @@MOOSEX_FATAL    = false

  def self.warn(x, *c)
    if @@MOOSEX_FATAL
      raise FatalError, "[MooseX] exception: #{x}",*c
    elsif @@MOOSEX_WARNINGS
      Kernel.warn("[MooseX] warning: #{x}") 
    end
  end
  
  def self.init(args={})
    if args.has_key? :warnings
      @@MOOSEX_WARNINGS = !! args[:warnings]
    end
    
    if args.has_key? :fatal
      @@MOOSEX_FATAL = !! args[:fatal]
    end

    if args.has_key?(:meta) && !! args[:meta]
      @@ALIAS = (args[:meta].is_a?(TrueClass))? :meta : args[:meta]
    end
    
    self
  end

  def initialize(*args) 
    if self.respond_to? :BUILDARGS
      args = self.BUILDARGS(*args)
    else
      args = args[0]          
    end 

    self.class.__moosex__meta.init(self, args || {})

    self.BUILD() if self.respond_to? :BUILD
  end

  def MooseX.included(class_or_module)

    class_or_module.extend(MooseX::Core)

    unless class_or_module.respond_to? :__moosex__meta
      meta = MooseX::Meta.new

      class_or_module.define_singleton_method(:__moosex__meta) { meta } 

      if @@ALIAS
        class_or_module.class_eval do 
          class_or_module.define_singleton_method(@@ALIAS) do 
            self.__moosex__meta
          end
        end  
        @@ALIAS = false
      end  
    end
        
    def class_or_module.init(*args)
      __moosex__meta.init_roles(*args)
      
      self
    end

    def class_or_module.inherited(subclass)
      old_meta = subclass.__moosex__meta

      meta = MooseX::Meta.new(old_meta)

      subclass.define_singleton_method(:__moosex__meta) { meta }
    end      
    
    def class_or_module.included(other_class_or_module)
      
      MooseX.included(other_class_or_module)

      other_class_or_module.__moosex__meta.load_from(self)

      if other_class_or_module.is_a? Class

        other_class_or_module.__moosex__meta.load_from_klass(self)

        self.__moosex__meta.init_klass(other_class_or_module).each_pair do |method_name, proc|
          other_class_or_module.class_eval do 
            define_method(method_name,&proc)
          end  
        end   

        other_class_or_module.__moosex__meta.verify_requires_for(other_class_or_module) 

      end 
    end
  end
end
