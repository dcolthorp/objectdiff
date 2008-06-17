require File.dirname(__FILE__) + '/spec_helper'
describe ObjectDiff, "#differences for an enumerable using a naive strategy" do
  class NaiveEnumerablyDiffable
    def initialize args
      @ary = args
    end
    
    include Enumerable
    include ObjectDiff::Strategies::Enumerable::Naive
    
    def each(&block)
      @ary.each(&block)
    end
  end
  
  def enum(*args)
    NaiveEnumerablyDiffable.new args
  end


  before do
    @diff = ObjectDiff.new
    ObjectDiff.array_strategy = :naive
  end

  describe "which are equal" do
    it "should not describe any differences" do
      @diff.execute enum(1,2,3), enum(1,2,3)
      @diff.differences.should be_empty
    end
  end
  
  describe "which are not equal" do
    it "should contain one difference per mismatch" do
      @diff.execute enum(:a,:b, :c), enum(:x, :b, :z)
      @diff.differences.size.should == 2
    end

    it "includes the path to the differing element" do
      @diff.execute enum(:a,:b, :c), enum(:x, :b, :z)
      
      @diff.differences[0].should include("actual[0]")
      @diff.differences[1].should include("actual[2]")
    end

    it "includes expected value" do
      @diff.execute enum(:a,:b, :c), enum(:x, :b, :z)
      
      @diff.differences[0].should include(":a")
      @diff.differences[1].should include(":c")
    end

    it "includes actual value" do
      @diff.execute enum(:a,:b, :c), enum(:x, :b, :z)
      
      @diff.differences[0].should include(":x")
      @diff.differences[1].should include(":z")
    end
    
    describe "when lengths differ" do
      it "should describe differences in length" do
        @diff.execute enum(:a,:b), enum(:a,:b,:c)
        @diff.differences.should_not be_empty
        @diff.differences[0].should include("length")
        @diff.differences[0].should match(/\b3\b/)
        @diff.differences[0].should match(/\b2\b/)
      end
          
      it "should describe missing elements" do
        @diff.execute enum(:a,:b,:c), enum(:a,:b)
        @diff.differences.should_not be_empty
        @diff.differences[1].should match(/:c\b/)
        @diff.differences[1].should match(/\b2\b/)
        @diff.differences[1].should include("missing")
      end
    
      it "should describe missing elements" do
        @diff.execute enum(:a,:b), enum(:a,:b,:c)
        @diff.differences.should_not be_empty
        @diff.differences[1].should match(/:c\b/)
        @diff.differences[1].should match(/\b2\b/)
        @diff.differences[1].should include("extra")
      end
    end
  end
end