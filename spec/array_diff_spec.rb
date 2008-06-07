require File.dirname(__FILE__) + '/spec_helper'
describe DiffContext, "#differences on arrays" do
  before do
    @diff_context = DiffContext.new "actual", 1000
  end

  describe "which are equal" do
    it "should not describe any differences" do
      @diff_context.continue "", [1,2,3], [1,2,3]
      @diff_context.differences.should be_empty
    end
  end
  
  describe "which are not equal" do
    it "should contain one difference per mismatch" do
      @diff_context.continue "", [:a,:b, :c], [:x, :b, :z]
      @diff_context.differences.size.should == 2
    end

    it "includes the path to the differing element" do
      @diff_context.continue "", [:a,:b, :c], [:x, :b, :z]
      
      @diff_context.differences[0].should include("actual[0]")
      @diff_context.differences[1].should include("actual[2]")
    end

    it "includes expected value" do
      @diff_context.continue "", [:a,:b, :c], [:x, :b, :z]
      
      @diff_context.differences[0].should include(":a")
      @diff_context.differences[1].should include(":c")
    end

    it "includes actual value" do
      @diff_context.continue "", [:a,:b, :c], [:x, :b, :z]
      
      @diff_context.differences[0].should include(":x")
      @diff_context.differences[1].should include(":z")
    end
    
    describe "when lengths differ" do
      it "should describe differences in length" do
        @diff_context.continue "", [:a,:b], [:a,:b,:c]
        @diff_context.differences.should_not be_empty
        @diff_context.differences[0].should include("length")
        @diff_context.differences[0].should match(/\b3\b/)
        @diff_context.differences[0].should match(/\b2\b/)
      end
          
      it "should describe missing elements" do
        @diff_context.continue "", [:a,:b,:c], [:a,:b]
        @diff_context.differences.should_not be_empty
        @diff_context.differences[1].should match(/:c\b/)
        @diff_context.differences[1].should match(/\b2\b/)
        @diff_context.differences[1].should include("was not present and should have been")
      end
    
      it "should describe missing elements" do
        @diff_context.continue "", [:a,:b], [:a,:b,:c]
        @diff_context.differences.should_not be_empty
        @diff_context.differences[1].should match(/:c\b/)
        @diff_context.differences[1].should match(/\b2\b/)
        @diff_context.differences[1].should include("should not have been present")
      end
    end
  end
end