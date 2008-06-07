class Array
  def object_diff other, diff
    ObjectDiff.diff_arrays self, other, diff
  end
end

class ObjectDiff
  def self.array_strategy=(strategy)
    @array_strategy = ObjectDiff::Array.const_get strategy.to_s.upcase
  end
  
  def self.diff_arrays a1, a2, diff
    (@array_strategy || Array::LCS).diff a1, a2, diff
  end
  
  module Array
    module NAIVE
      def self.diff a1, a2, diff
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
    
    module LCS
      def self.diff a1, a2, diff
        require 'rubygems'
        gem 'diff-lcs'
        require 'diff/lcs'

        Diff::LCS.traverse_balanced(a1, a2) do |difference|
          case difference.action
          when "!"
            diff.continue "[#{difference.new_position}]", difference.old_element, difference.new_element
            when "-"
              diff.report_missing "#{diff.current_name}[#{difference.new_position}]", difference.old_element
            when "+"
              diff.report_extra "#{diff.current_name}[#{difference.new_position}]", difference.new_element
          end
        end
      end
    end
  end
end