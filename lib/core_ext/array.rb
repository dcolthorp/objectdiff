class Array
  include ObjectDiff::Strategies::Enumerable::LCS
end

class ObjectDiff
  def self.array_strategy=(strategy)
    normalized_strategy_name = strategy.to_s.gsub(/\W/,'').downcase
    name = ObjectDiff::Strategies::Enumerable.constants.find{|c| c.downcase == normalized_strategy_name}
    raise "Couldn't find enumerable strategy named #{strategy}." if name.nil?
    array_strategy = ObjectDiff::Strategies::Enumerable.const_get name
    ::Array.class_eval do
      include array_strategy
    end
  end
end