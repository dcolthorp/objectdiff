class Object
  def diffs_with? other
    self.class == other.class
  end
  
  def object_diff other, diff
    if self != other
      diff.report_unequal "#{diff.current_name}", self, other
    end
  end
end
