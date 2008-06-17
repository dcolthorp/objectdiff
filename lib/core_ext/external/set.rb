ObjectDiff.external_strategies["Set"] = Module.new do
  def object_diff other, diff
    (self - other).each do |element|
      diff.report "#{diff.current_name} was missing #{diff.show element}"
    end
    
    (other - self).each do |element|
      diff.report "#{diff.current_name} had unexpected element #{diff.show element}"
    end
  end
end