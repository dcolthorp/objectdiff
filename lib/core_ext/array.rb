class Array
  include ObjectDiff::Strategies::Enumerable::LCS
end

class ObjectDiff
  def self.array_strategy=(strategy)
    normalized_strategy_name = strategy.to_s.gsub(/\W/,'').downcase
    name = ObjectDiff::Strategies::Enumerable.constants.find{|c| c.downcase == normalized_strategy_name}
    raise "Couldn't find strategy named #{strategy}." if name.nil?
    
    strategy = ObjectDiff::Strategies::Enumerable.const_get name
    ::Array.class_eval do
      include strategy
      
      # make sure the include overwrites the existing object diff, even if this has happened before
      strategy.instance_methods.each do |method|
        define_method method, strategy.instance_method(method)
      end
    end
  end
end