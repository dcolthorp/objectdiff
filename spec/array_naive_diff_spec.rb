require File.dirname(__FILE__) + '/spec_helper'
describe ObjectDiff, "#differences on arrays using the naive algorithm" do
  before do
    @diff = ObjectDiff.new
    ObjectDiff.array_strategy = :naive
  end

  describe "which are equal" do
    it "should not describe any differences" do
      @diff.execute [1,2,3], [1,2,3]
      @diff.differences.should be_empty
    end
  end
  
  describe "which are not equal" do
    it "should contain one difference per mismatch" do
      @diff.execute [:a,:b, :c], [:x, :b, :z]
      @diff.differences.size.should == 2
    end

    it "includes the path to the differing element" do
      @diff.execute [:a,:b, :c], [:x, :b, :z]
      
      @diff.differences[0].should include("actual[0]")
      @diff.differences[1].should include("actual[2]")
    end

    it "includes expected value" do
      @diff.execute [:a,:b, :c], [:x, :b, :z]
      
      @diff.differences[0].should include(":a")
      @diff.differences[1].should include(":c")
    end

    it "includes actual value" do
      @diff.execute [:a,:b, :c], [:x, :b, :z]
      
      @diff.differences[0].should include(":x")
      @diff.differences[1].should include(":z")
    end
    
    describe "when lengths differ" do
      it "should describe differences in length" do
        @diff.execute [:a,:b], [:a,:b,:c]
        @diff.differences.should_not be_empty
        @diff.differences[0].should include("length")
        @diff.differences[0].should match(/\b3\b/)
        @diff.differences[0].should match(/\b2\b/)
      end
          
      it "should describe missing elements" do
        @diff.execute [:a,:b,:c], [:a,:b]
        @diff.differences.should_not be_empty
        @diff.differences[1].should match(/:c\b/)
        @diff.differences[1].should match(/\b2\b/)
        @diff.differences[1].should include("missing")
      end
    
      it "should describe missing elements" do
        @diff.execute [:a,:b], [:a,:b,:c]
        @diff.differences.should_not be_empty
        @diff.differences[1].should match(/:c\b/)
        @diff.differences[1].should match(/\b2\b/)
        @diff.differences[1].should include("extra")
      end
    end
  end
end