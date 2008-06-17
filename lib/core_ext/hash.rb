class Hash
  def object_diff other, diff
    keys = self.keys | other.keys
    keys = keys.sort_by{|k| k.to_s}
    
    keys.each do |key|
      if self.has_key?(key) && other.has_key?(key)
        diff.continue "[#{key.inspect}]", self[key], other[key]
      elsif !self.has_key?(key)
        diff.report_extra "#{diff.current_name}[#{key.inspect}]", other[key]
      elsif !other.has_key?(key)
        diff.report_missing "#{diff.current_name}[#{key.inspect}]", self[key]
      end
    end
  end
end

