if defined? OpenStruct
  class OpenStruct
    def object_diff other, diff
      keys = self.table.keys | other.table.keys
      keys = keys.sort_by{|k| k.to_s}

      keys.each do |key|
        if self.table.has_key?(key) && other.table.has_key?(key)
          diff.continue ".#{key}", self.table[key], other.table[key]
        elsif !self.table.has_key?(key)
          diff.report_extra "#{diff.current_name}.#{key}", other.table[key]
        elsif !other.table.has_key?(key)
          diff.report_missing "#{diff.current_name}.#{key}", self.table[key]
        end
      end
    end
  end
end