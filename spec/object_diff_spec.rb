require File.dirname(__FILE__) + '/spec_helper'
describe ObjectDiff, "#differences" do
  before do
    @diff = ObjectDiff.new
  end

  describe "on two objects" do
    describe "which are equal" do
      it "should not describe any differences" do
        object = Object.new
        @diff.execute object, object
        @diff.differences.should be_empty
      end
    end

    describe "which are not equal" do
      it "should not describe any differences" do
        object1 = Object.new
        object2 = Object.new
        @diff.execute object1, object2
        @diff.differences.should_not be_empty
        @diff.differences.first.should match(object1.inspect.to_regexp)
        @diff.differences.first.should match(object1.inspect.to_regexp)
      end
    end
  end
  
  describe "when one object contains a circular reference" do
    before do
      # disable all strategies that cannot handle circular references
      ObjectDiff.array_strategy = :naive
    end
    
    describe "and the two objects are identical" do
      it "should not have differences" do
        circular1 = []
        circular2 = []
        circular1.push circular1
        circular2.push circular1

        @diff.execute circular1, circular2
        @diff.differences.should be_empty
      end
    end
    
    describe "and the two objects are not identical but have the same circular structure" do
      it "should not have differences" do
        circular1 = []
        circular2 = []
        circular1.push circular1
        circular2.push circular2

        @diff.execute circular1, circular2
        @diff.differences.should be_empty
      end
    end
    
    describe "and the two objects are not equal" do
      it "should say expected it (path same object higher up in the hierarchy)" do
        # circular[0][0][0] references circular[0]
        circular = [[[]]]
        circular[0][0].push circular[0]

        @diff.execute circular, [[[:foo]]]
        @diff.differences.size.should == 1
        @diff.differences[0].should include("actual[0][0][0]")
        @diff.differences[0].should include(":foo")
        @diff.differences[0].should include("(actual[0])")
      end
    end
  end
  
  describe "on two deeply destructurable objects which are not equal" do
    it "should describe the differences between those two objects" do
      o1 = [{:a => [:x]}]
      o2 = [{:a => [:y]}]
      @diff.execute o1, o2
      
      @diff.differences.size.should == 1
      @diff.differences[0].should include("actual[0][:a][0]")
      @diff.differences[0].should include(":x")
      @diff.differences[0].should include(":y")
    end
  end
  
  describe "when max_diff_size is specified" do
    class DiffableClass
      def initialize continue_expected, continue_actual
        @continue_expected = continue_expected
        @continue_actual = continue_actual
      end
      
      def object_diff other, diff
        10.times do |i|
          diff.report "#{i}"
        end
        diff.continue " @continue", @continue_expected, @continue_actual
      end
    end
    
    before do
      @inside1 = mock("Inside 1")
      @inside2 = mock("Inside 2")
      
      @inside1.stub!(:object_diff)
      
      @object = DiffableClass.new @inside1, @inside2
    end
    
    context "when the size limit is reached" do
      it "limit the size of the diff to the limit" do
        @diff = ObjectDiff.new :max_diff_size => 3
        @diff.execute @object, @object
        @diff.differences.size.should == 3
      end
    
      it "should say that it reached its limit" do
        @diff = ObjectDiff.new :max_diff_size => 3
        @diff.execute @object, @object
        @diff.limit_reached?.should be_true
      end
      
      it "does not recurse into component objects" do
        @inside1.should_receive(:object_diff).never
        @diff = ObjectDiff.new :max_diff_size => 3
        @diff.execute @object, @object
      end
    end
    
    context "when the size limit is not reached" do
      it "limit the size of the diff to the limit" do
        @diff = ObjectDiff.new :max_diff_size => 300
        @diff.execute @object, @object
        @diff.differences.size.should == 10
      end
    
      it "should say that it reached its limit" do
        @diff = ObjectDiff.new :max_diff_size => 300
        @diff.execute @object, @object
        @diff.limit_reached?.should be_false
      end
      
      it "does not recurse into component objects" do
        @diff = ObjectDiff.new :max_diff_size => 300
        @inside1.should_receive(:object_diff).once.with(@inside2, anything)
        @diff.execute @object, @object
      end
    end
    
  end
end