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
require "weakref"

module MooseX
  @@MOOSEX_WARNINGS = true
  @@MOOSEX_FATAL    = false
  
  def self.warn(x, *c)
    raise FatalError, "[MooseX] exception: #{x}",*c if @@MOOSEX_FATAL
    Kernel.warn("[MooseX] warning: #{x}") if @@MOOSEX_WARNINGS
  end
  
  def self.init(args={})
    if args.has_key? :warnings
      @@MOOSEX_WARNINGS = !! args[:warnings]
    end
    
    if args.has_key? :fatal
      @@MOOSEX_FATAL = !! args[:fatal]
    end
    
    self
  end

  def MooseX.included(c)
  
    c.extend(MooseX::Core)

    def c.init(*args)
      __moosex__meta.roles.each{|role| role.call(*args)}
      
      self
    end
    
    def c.included(x)
      
      MooseX.included(x)
      x.__moosex__meta.load_from(self.__moosex__meta)

      return unless x.is_a? Class

      x.__moosex__meta.load_hooks(self.__moosex__meta)
      self.__moosex__meta.init_klass(x)

      x.__moosex__meta.requires.each do |method|
        unless x.public_instance_methods.include? method
          MooseX.warn "you must implement method '#{method}' in #{x} #{x.class}: required"# if $MOOSEX_DEBUG
        end 
      end     
    end

    meta = MooseX::Meta.new

    unless c.respond_to? :__moosex__meta
      c.class_exec do 
        define_singleton_method(:__moosex__meta) { meta }
        define_singleton_method(:__moosex__meta_define_method) do |method_name, &proc| 
          define_method(method_name, proc)
        end       
      end
    end
        
    def initialize(*args) 
      if self.respond_to? :BUILDARGS
        args = self.BUILDARGS(*args)
      else
        args = args[0]          
      end 
      
      self.class.__moosex__meta().init(self, args || {})

      self.BUILD() if self.respond_to? :BUILD
    end

    def c.inherited(subclass)
      subclass.class_exec do 
        old_meta = subclass.__moosex__meta

        meta = MooseX::Meta.new(old_meta)

        define_singleton_method(:__moosex__meta) { meta }
      end       
    end      
  end
end
