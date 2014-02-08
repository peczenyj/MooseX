#
# This example was ported from
# https://metacpan.org/pod/Moose::Cookbook::Basics::BinaryTree_BuilderAndLazyBuild
#
# What is a Binary Tree?
# http://en.wikipedia.org/wiki/Binary_treehttp://en.wikipedia.org/wiki/Binary_tree

require 'moosex'

class BinaryTree
  include MooseX

  has node: {
    is: :rw,
    predicate: :full?,          # full? indicate there is a value
  }

  has parent: { 
    is: :rw,
    isa: BinaryTree,
    predicate: true,            # will inject has_parent? 
  }

  has [ :left, :right ], {
    is: :rw,
    lazy: true,
    isa: BinaryTree,
    predicate: true,            # will inject has_left? has_right?
    builder: :build_child_tree,
  }
  
  def build_child_tree
    BinaryTree.new( parent: self )
  end

  before(:left=, :right=) do |this, tree|
    tree.parent= this
  end

  def <<(value)
    if ! full?
     self.node= value     # <= here is ambiguous, without self., if it is 
    elsif (value > node ) # method or an assignment to a local variable! 
      left << value
    else
      right << value
    end
  end

  def to_s
    return "?" unless full?
    "{#{left} <= #{node} => #{right}}"
  end
end

bt = BinaryTree.new()

bt << 4   # 1st node
bt << 8   # 2nd node, to the left of 4
bt << 1   # 3rd node, to the right if 4
bt.left.right = BinaryTree.new(node: 7)

puts "bt.node=#{bt.node}, bt.left.parent.node=#{bt.left.parent.node}"
puts "bt.left.right.parent.node=#{bt.left.right.parent.node}"
puts ""
puts ""
puts "#{bt}"

puts <<EOF

# this example will print
# {{? <= 8 => {? <= 7 => ?}} <= 4 => {? <= 1 => ?}}
# 
# this is the equivalent to this tree
#
#      4
#   8     1
#  ? 7   ? ?
#
# have fun :)
EOF

