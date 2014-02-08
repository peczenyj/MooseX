#
# This example was ported from
# https://metacpan.org/pod/Moose::Cookbook::Basics::Genome_OverloadingSubtypesAndCoercion

require 'moosex'
require 'moosex/types'

class Human
  include MooseX
  include MooseX::Types

  has sex: {
    is: :rw,
    isa: isEnum(:male, :female),
    required: true,
  }

  has [:mother, :father], {
    is: :rw,
    isa: Human,
  }

  def +(partner)
    raise "ops" if self.sex.eql?(partner.sex)

    mother, father = (self.sex === :female)? [self, partner] : [partner, self]

    sex = [:male, :female].shuffle.shift

    Human.new(sex: sex, mother: mother, father: father)
  end
end

adam    = Human.new( sex: :male )
eve     = Human.new( sex: :female )
lilith  = Human.new( sex: :female )

childs = [] 
childs << adam + eve
childs << eve + adam

puts childs.inspect

begin
  eve + lilith
rescue => e
  p e
end
