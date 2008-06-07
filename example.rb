require File.dirname(__FILE__) + "/lib/object_diff"

def diff o1, o2
  @diff = ObjectDiff.new
  @diff.execute o1, o2
  differences = @diff.differences
  differences << "..." if @diff.limit_reached?
  differences
end

class Foo
  def initialize a,b,c
    @a = a
    @b = b
    @c = c
  end
  
  attr_reader :a, :b, :c
  
  def object_diff other, diff
    diff.continue ".a", @a, other.a
    diff.continue ".b", @b, other.b
    diff.continue ".c", @c, other.c
  end
end

class Bar
end

if $0 == __FILE__
  expected = [
    {
      :mismatch => Foo.new(1,2,3),
      :destructured_mismatch => Foo.new(1,2,3),
      :missing => 1,
      :type_mismatch => [],
      :ostruct => OpenStruct.new(:a => 1, :b => 2)
    },
    2,
    3,
    4
  ]
  actual = [
    {
      :mismatch => Bar.new,
      :destructured_mismatch => Foo.new(3,2,1),
      :type_mismatch => 2,
      :extra => {},
      :ostruct => OpenStruct.new(:b => nil, :c => 3)
    },
    12,
    13
  ]
  
  expected[0][:circular] = {:reference => expected[0]}
  actual[0][:circular] = {:reference => nil}
  
  require 'pp'
  puts "*"*100
  puts "Example standard explanation"
  puts "expected <#{expected.inspect}>\n but got <#{actual.inspect}>"
  
  puts "*"*100
  puts "Example explanation based on ObjectDiff"
  puts "Expected value differed from actual"
  pp diff(expected, actual)
    
  
  a1 = (0..11).to_a
  a2 = [-1,0,1,4,5,6,:a,:b,11,12]
  
  puts "*"*100
  puts "Example using naive array diff"
  ObjectDiff.array_strategy = :naive
  pp diff(a1, a2)
  
  puts "*"*100
  puts "Example using smart, LCS-based array diff"
  ObjectDiff.array_strategy = :lcs
  pp diff(a1, a2)
end