module ObjectDiff::Strategies
  module Enumerable
    module LCS
      extend ObjectDiff::SwitchableDiff
      
      def object_diff other, diff
        a1 = ObjectDiff::Strategies::Enumerable.to_array self
        a2 = ObjectDiff::Strategies::Enumerable.to_array other
        
        require 'rubygems'
        gem 'diff-lcs'
        require 'diff/lcs'

        Diff::LCS.traverse_balanced(a1, a2) do |difference|
          case difference.action
          when "!"
            diff.continue "[#{difference.new_position}]", difference.old_element, difference.new_element
          when "+"
            diff.report_extra "#{diff.current_name}[#{difference.new_position}]", difference.new_element
          when "-"
            if difference.new_position == 0
              diff.report "#{diff.current_name} was missing element at beginning from #{difference.old_position}, #{diff.show difference.old_element}"
            elsif difference.new_position >= a2.length
              diff.report "#{diff.current_name} was missing element at end from #{difference.old_position}, #{diff.show difference.old_element}"
            else
              diff.report "#{diff.current_name} was missing element at #{difference.new_position} from #{difference.old_position}, #{diff.show difference.old_element}"
            end
          end
        end
      end
    end
  end
end