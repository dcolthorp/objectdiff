require File.dirname(__FILE__) + "/lib/object_diff"

def diff o1, o2
  @diff = ObjectDiff.new "actual", 20
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
  puts "Expected value differed from actual"
  pp diff(expected, actual)
  
  puts "\n"*5
  
  puts "expected <#{expected.inspect}> but got <#{actual.inspect}>"
end