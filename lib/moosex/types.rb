module MooseX
  module Types

    def Types.included(c)
      c.extend(MooseX::Types::Core)
    end

    class TypeCheckError < TypeError

    end

    module Core 

      # TODO
      # String 
      # format
      # length (min, max, between, is)
      # add custom message
      # integer / number odd, even, >=, <=, etc
      # allow new/blank
      # required :method?

      # Types::Numeric
      # PositiveNum
      # PositiveOrZeroNum
      # PositiveInt
      # PositiveOrZeroInt
      # NegativeNum
      # NegativeOrZeroNum
      # NegativeInt
      # NegativeOrZeroInt
      # SingleDigit

      def createValidator(message, &block)
        l = block
        l.define_singleton_method(:to_s) { message }
        l
      end

      def isAny
        createValidator("[Any]") {|value| }
      end

      def isConstant(constant_value)
        createValidator("[Constant: '#{constant_value}' (#{constant_value.class})]") do |value|
          unless value === constant_value
            raise TypeCheckError,"Constant violation: value '#{value}' (#{value.class}) is not '#{constant_value}' (#{constant_value.class})"
          end 
        end
      end       

      def isType(type)
        return type if type.is_a?(Proc)

        createValidator("[Type #{type}]") do |value|
          raise TypeCheckError, "Type violation: value '#{value}' (#{value.class}) is not an instance of [Type #{type}]" unless value.is_a?(type)
        end
      end

      alias_method :isInstanceOf, :isType
      alias_method :isConsumerOf, :isType

      def hasMethods(*methods)
        createValidator("[hasMethods #{methods}]") do |object|
          methods.each do |method|
            unless object.respond_to? method.to_sym
              raise TypeCheckError, "hasMethods violation: object #{object} (#{object.class}) should implement method #{method}"
            end 
          end
        end
      end

      def isAllOf(*conditions)
        createValidator("[AllOf [#{conditions.map{|t| t.to_s }.join(', ')}]]") do |value|
          begin
            conditions.each { |c| isType(c).call(value) }
          rescue TypeCheckError => e
            raise TypeCheckError, "AllOf Check violation: caused by [#{e}]"
          end 
        end
      end

      def isAnyOf(*conditions)
        conditions = conditions.flatten
        createValidator("[AnyOf [#{conditions.map{|t| t.to_s }.join(', ')}]]") do |value|

          find = false          
          exceptions = []

          for c in conditions
            begin
              isType(c).call(value)
              find = true
              break
            rescue TypeCheckError => ex
              exceptions << ex
            rescue => e
              raise TypeCheckError, "unexpected exception #{e}"         
            end
          end

          raise TypeCheckError, "AnyOf Check violation: caused by [#{exceptions.map{|e| e.to_s}.join', '}]" unless find
        end
      end

      def isEnum(*possible_values)
        possible_constants = possible_values.flatten.map do |value| 
          isConstant(value) 
        end

        createValidator("[Enum #{possible_values}]") do |value|
          begin 
            isAnyOf(possible_constants).call(value)
          rescue TypeCheckError => e
            raise TypeCheckError, "Enum Check violation: value '#{value}' (#{value.class}) is not #{possible_values}"
          end
        end
      end

      def isNot(condition)
        createValidator("[NOT #{condition.to_s}]") do |value|
          success = false
          begin
            condition.call(value)
            success = true
          rescue TypeCheckError => e
            nil
          end

          if success
            raise TypeCheckError, "Not violation: value '#{value}' (#{value.class}) is not #{condition.to_s}"
          end 
        end
      end

      def isMaybe(type)
        createValidator("[Maybe #{type.to_s}]") do |value|
          begin
            isAnyOf(isType(type), isConstant(nil)).call(value)
          rescue TypeCheckError => e
            raise TypeCheckError, "Maybe violation: caused by #{e}"
          end
        end   
      end

      def isArray(type=nil)
        type = isAny if type.nil?

        createValidator "[Array #{type.to_s}]" do |array|
          isType(Array).call(array)

          array.each do |item| 
            begin
              isType(type).call(item)
            rescue TypeCheckError => e
              raise TypeCheckError, "Array violation: caused by #{e}"
            end
          end
        end
      end 

      def isHash(map={})
        if map.empty?
          map = {isAny => isAny }
        end

        keyType, valueType = map.shift

        createValidator "[Hash #{keyType.to_s} => #{valueType.to_s}]" do |hash|
          isType(Hash).call(hash)

          hash.each_pair do| key, value| 
            begin
              isType(keyType).call(key)
              isType(valueType).call(value)
            rescue TypeCheckError => e
              raise TypeCheckError, "Hash violation: caused by #{e}"
            end
          end
        end
      end

      def isTuple(*types)

        size_validation = ->(tuple) do
          unless tuple.size == types.size
            raise TypeCheckError, "Tuple violation: size should be #{types.size} instead #{tuple.size}"
          end              
        end

        individual_validations = create_individual_validations_for_tuples(types)

        proc = isAllOf(
            isType(Array),
            size_validation,
            *individual_validations,
          )

        createValidator("[Tuple [#{types.map{|t| t.to_s}.join ', '}]]", &proc)
      end

      def isSet(type=nil)
        type = isAny if type.nil?

        proc = isAllOf(
            isArray(type),
            ->(set) do
              if set.uniq.size != set.size
                raise TypeCheckError, "Set violation: has one or more non unique elements"
              end 
            end,
          )

        createValidator("[Set #{type.to_s}]", &proc)
      end

      private
      def create_individual_validations_for_tuples(types)
        individual_validations = []
        types.each_index do |index|        
          individual_validations << ->(tuple) do
            begin
              isType(types[index]).call(tuple[index])
            rescue TypeCheckError => e
              raise TypeCheckError, "Tuple violation: on position #{index} caused by #{e}"
            end
          end
        end

        individual_validations        
      end      

    end

  end 

end 
