require File.dirname(__FILE__) + '/spec_helper'
describe DiffContext, "#differences" do
  before do
    @diff_context = DiffContext.new "actual", 1000
  end

  describe "on two objects" do
    describe "which are equal" do
      it "should not describe any differences" do
        object = Object.new
        @diff_context.continue "", object, object
        @diff_context.differences.should be_empty
      end
    end

    describe "which are not equalequal" do
      it "should not describe any differences" do
        object1 = Object.new
        object2 = Object.new
        @diff_context.continue "", object1, object2
        @diff_context.differences.should_not be_empty
        @diff_context.differences.first.should match(object1.inspect.to_regexp)
        @diff_context.differences.first.should match(object1.inspect.to_regexp)
      end
    end
  end
  
  describe "when one object contains a circular reference" do
      describe "and the two objects are identical" do
        it "should not have differences" do
          circular1 = []
          circular2 = []
          circular1.push circular1
          circular2.push circular1

          @diff_context.continue "", circular1, circular2
          @diff_context.differences.should be_empty
        end
      end
      
      describe "and the two objects are not identical but have the same circular structure" do
        it "should not have differences" do
          circular1 = []
          circular2 = []
          circular1.push circular1
          circular2.push circular2

          @diff_context.continue "", circular1, circular2
          @diff_context.differences.should be_empty
        end
      end
      
      describe "and the two objects are not equal" do
        it "should not have differences" do
          circular = [[]]
          circular[0].push circular

          @diff_context.continue "", circular, [[:foo]]
          @diff_context.differences.size.should == 1
        end
      end
  end
  
  describe "on two deeply destructurable objects which are not equal" do
    it "should describe the differences between those two objects" do
      o1 = [{:a => [:x]}]
      o2 = [{:a => [:y]}]
      @diff_context.continue "", o1, o2
      
      @diff_context.differences.size.should == 1
      @diff_context.differences[0].should include("actual[0][:a][0]")
      @diff_context.differences[0].should include(":x")
      @diff_context.differences[0].should include(":y")
    end
  end

  describe "on two hashes" do
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
    end
  end
end