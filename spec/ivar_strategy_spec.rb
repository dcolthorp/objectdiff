require File.dirname(__FILE__) + '/spec_helper'

describe ObjectDiff::Strategies::IvarStrategy do
  class Variabled
    def initialize values
      values.each_pair do |ivar, value|
        instance_variable_set "@#{ivar}", value
      end
    end
    
    include ObjectDiff::Strategies::IvarStrategy
  end
  
  describe "#object_diff" do
    it "should report differences in instance variables in alphabetical order" do
      @diff = ObjectDiff.new
      @target = Variabled.new :a => 1, :b => 2, :c => 3
      @other = Variabled.new :a => :x, :b => :y, :c => :z
      
      @diff.execute @target, @other
      @diff.differences.length.should == 3
      @diff.differences[0].should include("@a")
      @diff.differences[1].should include("@b")
      @diff.differences[2].should include("@c")
    end
    
    it "should recursively diff child entries" do
      @diff = ObjectDiff.new
      @target = Variabled.new :a => Variabled.new(:b => 1)
      @other = Variabled.new :a => Variabled.new(:b => 2)
      
      @diff.execute @target, @other
      @diff.differences.length.should == 1
      @diff.differences[0].should include("@a@b")
      @diff.differences[0].should include("1")
      @diff.differences[0].should include("2")
    end
  end
end