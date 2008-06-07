require File.dirname(__FILE__) + '/spec_helper'
describe DiffContext, "#differences on hashes" do
  before do
    @diff_context = DiffContext.new "actual", 1000
  end

  describe "which are equal" do
    it "should not describe any differences" do
      @diff_context.continue "", {:a => 1}, {:a => 1}
      @diff_context.differences.should be_empty
    end
  end
  
  describe "which are not equal" do
    it "should have one difference for each different entry" do
      hash1 = {:a => 1, :b => 2, :c => 3}
      hash2 = {:a => 5, :b => 2, :c => 4}
      @diff_context.continue "", hash1, hash2
      @diff_context.differences.size.should == 2
      @diff_context.differences[0].should include("actual[:a]")
      @diff_context.differences[1].should include("actual[:c]")
    end
    
    it "should contain one difference per mismatch" do
      hash1 = {:a => 1, :b => 2, :c => 3}
      hash2 = {:a => 5, :b => 2, :c => 4}
      @diff_context.continue "", hash1, hash2
      @diff_context.differences.size.should == 2
    end

    it "includes the path to the differing element" do
      hash1 = {:a => 1, :b => 2, :c => 3}
      hash2 = {:a => 5, :b => 2, :c => 4}
      @diff_context.continue "", hash1, hash2
      
      @diff_context.differences[0].should include("actual[:a]")
      @diff_context.differences[1].should include("actual[:c]")
    end

    it "includes expected value" do
      hash1 = {:a => 1, :b => 2, :c => 3}
      hash2 = {:a => 5, :b => 2, :c => 4}
      @diff_context.continue "", hash1, hash2
      
      @diff_context.differences[0].should match(/1/)
      @diff_context.differences[1].should match(/3/)
    end

    it "includes actual value" do
      hash1 = {:a => 1, :b => 2, :c => 3}
      hash2 = {:a => 5, :b => 2, :c => 4}
      @diff_context.continue "", hash1, hash2
      
      @diff_context.differences[0].should match(/5/)
      @diff_context.differences[1].should match(/4/)
    end
    
    it "points out missing expected values" do
      hash1 = {:a => :x, :b => :y, :c => :z}
      hash2 = {:a => :x, :b => :y}
      @diff_context.continue "", hash1, hash2
      
      @diff_context.differences[0].should match(/:c\b/)
      @diff_context.differences[0].should match(/:z\b/)
      @diff_context.differences[0].should include("was not present")
    end

    it "points out missing expected values" do
      hash1 = {:a => :x, :b => :y}
      hash2 = {:a => :x, :b => :y, :c => :z}
      @diff_context.continue "", hash1, hash2

      @diff_context.differences[0].should match(/:c\b/)
      @diff_context.differences[0].should match(/:z\b/)
      @diff_context.differences[0].should include("should not have been present")
    end
  end
end