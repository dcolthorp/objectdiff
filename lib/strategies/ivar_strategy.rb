module ObjectDiff::Strategies
  module IvarStrategy
    def object_diff other, diff
      instance_variables.sort.each do |ivar|
        diff.continue ivar, instance_variable_get(ivar), other.instance_variable_get(ivar)
      end
    end
  end
end