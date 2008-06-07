require File.dirname(__FILE__) + '/spec_helper'

require 'set'

describe DiffContext, "#differences on sets" do
  before do
    @diff = ObjectDiff.new
  end

  describe "which are equal" do
    it "should not describe any differences" do
      set1 = Set.new [:a, "b", [:c]]
      set2 = Set.new [:a, "b", [:c]]

      @diff.execute set1, set2
      @diff.differences.size.should == 0
    end
  end
  
  describe "which are not equal" do
    it "points out missing expected values" do
      set1 = Set.new [:a, :b, :c]
      set2 = Set.new [:a, :b]
      @diff.execute set1, set2
      
      @diff.differences[0].should match(/:c\b/)
      @diff.differences[0].should include("was missing")
    end

    it "points out unexpected values" do
      set1 = Set.new [:a, :b]
      set2 = Set.new [:a, :b, :c]
      @diff.execute set1, set2

      @diff.differences[0].should match(/:c\b/)
      @diff.differences[0].should include("had unexpected element")
    end
  end
end