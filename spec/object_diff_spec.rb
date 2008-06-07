require File.dirname(__FILE__) + '/spec_helper'
describe DiffContext, "#differences" do
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

    describe "which are not equalequal" do
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
  
  # describe "when one object contains a circular reference" do
  #     describe "and the two objects are identical" do
  #       it "should not have differences" do
  #         circular1 = []
  #         circular2 = []
  #         circular1.push circular1
  #         circular2.push circular1
  # 
  #         @diff.execute circular1, circular2
  #         @diff.differences.should be_empty
  #       end
  #     end
  #     
  #     describe "and the two objects are not identical but have the same circular structure" do
  #       it "should not have differences" do
  #         circular1 = []
  #         circular2 = []
  #         circular1.push circular1
  #         circular2.push circular2
  # 
  #         @diff.execute circular1, circular2
  #         @diff.differences.should be_empty
  #       end
  #     end
  #     
  #     describe "and the two objects are not equal" do
  #       it "should not have differences" do
  #         circular = [[]]
  #         circular[0].push circular
  # 
  #         @diff.execute circular, [[:foo]]
  #         @diff.differences.size.should == 1
  #       end
  #     end
  # end
  
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
end