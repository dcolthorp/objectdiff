module ObjectDiff::Strategies
  module Enumerable
    module Naive
      def object_diff other, diff
        a1 = ObjectDiff::Strategies::Enumerable.to_array self
        a2 = ObjectDiff::Strategies::Enumerable.to_array other
        
        unless a1.length == a2.length
          diff.report_unequal "#{diff.current_name}.length", a1.length, a2.length
        end
      
        [a1.length, a2.length].min.times do |i|
          diff.continue "[#{i}]", a1[i], a2[i]
        end
      
        if a1.length < a2.length
          a1.length.upto(a2.length-1) do |i|
            diff.report_extra "#{diff.current_name}[#{i}]", a2[i]
          end
        elsif a1.length > a2.length
          a2.length.upto(a1.length-1) do |i|
            diff.report_missing "#{diff.current_name}[#{i}]", a1[i]
          end
        end
      end
    end
  end
end