require File.dirname(__FILE__) + '/spec_helper'
describe ObjectDiff, "#differences on hashes" do
  before do
    @diff = ObjectDiff.new
  end

  describe "which are equal" do
    it "should not describe any differences" do
      @diff.execute({:a => 1}, {:a => 1})
      @diff.differences.should be_empty
    end
  end
  
  describe "which are not equal" do
    it "should have one difference for each different entry" do
      hash1 = {:a => 1, :b => 2, :c => 3}
      hash2 = {:a => 5, :b => 2, :c => 4}
      @diff.execute hash1, hash2
      @diff.differences.size.should == 2
      @diff.differences[0].should include("actual[:a]")
      @diff.differences[1].should include("actual[:c]")
    end
    
    it "should contain one difference per mismatch" do
      hash1 = {:a => 1, :b => 2, :c => 3}
      hash2 = {:a => 5, :b => 2, :c => 4}
      @diff.execute hash1, hash2
      @diff.differences.size.should == 2
    end

    it "includes the path to the differing element" do
      hash1 = {:a => 1, :b => 2, :c => 3}
      hash2 = {:a => 5, :b => 2, :c => 4}
      @diff.execute hash1, hash2
      
      @diff.differences[0].should include("actual[:a]")
      @diff.differences[1].should include("actual[:c]")
    end

    it "includes expected value" do
      hash1 = {:a => 1, :b => 2, :c => 3}
      hash2 = {:a => 5, :b => 2, :c => 4}
      @diff.execute hash1, hash2
      
      @diff.differences[0].should match(/1/)
      @diff.differences[1].should match(/3/)
    end

    it "includes actual value" do
      hash1 = {:a => 1, :b => 2, :c => 3}
      hash2 = {:a => 5, :b => 2, :c => 4}
      @diff.execute hash1, hash2
      
      @diff.differences[0].should match(/5/)
      @diff.differences[1].should match(/4/)
    end
    
    it "points out missing expected values" do
      hash1 = {:a => :x, :b => :y, :c => :z}
      hash2 = {:a => :x, :b => :y}
      @diff.execute hash1, hash2
      
      @diff.differences[0].should match(/:c\b/)
      @diff.differences[0].should match(/:z\b/)
      @diff.differences[0].should include("missing")
    end

    it "points out unexpected values" do
      hash1 = {:a => :x, :b => :y}
      hash2 = {:a => :x, :b => :y, :c => :z}
      @diff.execute hash1, hash2

      @diff.differences[0].should match(/:c\b/)
      @diff.differences[0].should match(/:z\b/)
      @diff.differences[0].should include("extra")
    end
  end
end