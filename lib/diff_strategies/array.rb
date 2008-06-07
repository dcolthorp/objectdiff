class Array
  def object_diff other, diff
    unless self.length == other.length
      diff.report_unequal "#{diff.current_name}.length", self.length, other.length
    end
    
    [self.length, other.length].min.times do |i|
      diff.continue "[#{i}]", self[i], other[i]
    end
    
    if self.length < other.length
      self.length.upto(other.length-1) do |i|
        diff.report_extra "#{diff.current_name}[#{i}]", other[i]
      end
    elsif self.length > other.length
      other.length.upto(self.length-1) do |i|
        diff.report_missing "#{diff.current_name}[#{i}]", self[i]
      end
    end
  end
end
