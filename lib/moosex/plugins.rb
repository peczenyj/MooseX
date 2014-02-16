module MooseX
  module Plugins
    class Chained
      def prepare(options)

      end
      
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
      
      def prepare(options)
        options[:traits] ||= []
        if(options[:expires])
          options[:traits].unshift( MooseX::Traits::Expires.with(options[:expires]) )
        end
        
        unless options[:clearer]
          options[:clearer] = true
        end    
      end
      
      def process(options)
       expires = options.delete(:expires) || nil

       if expires
         lazy      = @this.attribute_map[:lazy]
         clearer   = @this.attribute_map[:clearer]
         reader    = @this.attribute_map[:reader]

         if reader && clearer && lazy
           reader_proc = @this.methods[reader]
           @this.methods[reader]  = ->(this) do
             value = reader_proc.call(this)
             unless value.valid?
               this.__send__(clearer)
               value = reader_proc.call(this)
             end
             value
           end
         end
       end

       @this.attribute_map[:expires] = expires
      end
    end

  end
end