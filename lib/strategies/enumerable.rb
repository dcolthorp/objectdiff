module ObjectDiff::Strategies
  module Enumerable
    def self.to_array enumerable
      return enumerable if enumerable.is_a? Array
      a = []
      enumerable.each do |element|
        a << element
      end
      a
    end
  end
end