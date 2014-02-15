require 'moosex'
require 'moosex/attribute'

module MooseX
  module AttributeModifiers
    module ThirdParty
      class Chained
        def initialize(this)
          @this = this
        end
        def process(options, attr_symbol)
         
         chained = !! options.delete(:chained)
         
         if chained
           writter  = @this.attribute_map[:writter]
           old_proc = @this.methods[ writter ]
           @this.methods[writter] = ->(this, value) { old_proc.call(this, value); this }   
         end
         
         chained
        end
     end
    end
  end  
end

module MyPlugin
  def self.included(x)
    x.meta.add_plugin(:chained)
  end
end

class Z
  include MooseX.init(meta: true)
  include MyPlugin

  has :foo, {
    writter: :set_foo,
    chained: true,
  }
  
  has :bar, {
    writter: :set_bar,
    chained: false,
  }
end

a1 = Z.new
a2 = Z.new

puts a1.set_foo(1).foo

puts a2.set_bar(1)#.bar