module MooseX
  module Plugins
    class Chained
      def initialize(this)
        @this = this
      end
      def process(options)
       chained = !! options.delete(:chained)

       if chained
         writter  = @this.attribute_map[:writter]
         old_proc = @this.methods[ writter ]
         @this.methods[writter] = ->(this, value) { old_proc.call(this, value); this }   
       end

      @this.attribute_map[:chained] = chained
      end
    end
    
    class ExpiredAttribute
      def initialize(this)
        @this = this
      end
      def process(options)
       expires = options.delete(:expires) || nil

       if expires
         lazy      = @this.attribute_map[:lazy]
         clearer   = @this.attribute_map[:clearer]
         predicate = @this.attribute_map[:predicate]
         reader    = @this.attribute_map[:reader]
         writter   = @this.attribute_map[:writter]

         old_traits= @this.attribute_map[:traits]

         @this.attribute_map[:traits]  = ->(this) do
           MooseX::Traits::Expires.new([ old_traits.call(this), expires ])
         end

         if reader && clearer && lazy
           reader_proc = @this.generate_reader
           @this.methods[reader]  = ->(this) do
             x = reader_proc.call(this)
             unless x.valid?
               this.__send__(clearer)
               x = reader_proc.call(this)
             end
             x
           end
         elsif reader
            @this.methods[reader] = @this.generate_reader
         end
         if writter
           @this.methods[writter] = @this.generate_writter
          end  
       end

       @this.attribute_map[:expires] = expires
      end
    end

  end
end