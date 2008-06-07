require 'ostruct'

class ObjectDiff
  DEFAULT_SIZE_LIMIT = 20

  def initialize args={}
    args = {
      :other_name => "actual",
      :max_diff_size => DEFAULT_SIZE_LIMIT
    }.merge(args)
    
    @context = DiffContext.new args[:other_name], args[:max_diff_size]
  end
  
  def limit_reached?
    @context.limit_reached?
  end
  
  def execute left, right
    @context.continue "", left, right
  end
  
  def differences
    @context.differences
  end
  
  def self.external_strategies
    @@external_strategies ||= {}
  end
end

Dir[File.dirname(__FILE__) + "/diff_strategies/**/*.rb"].each do |strategy|
  require strategy
end

class Object
  def diffs_with? other
    self.class == other.class
  end
  
  def object_diff other, diff
    if ObjectDiff.external_strategies.has_key?(self.class.name)
      extend ObjectDiff.external_strategies[self.class.name]
      return self.object_diff(other, diff)
    end
    
    if self != other
      diff.report_unequal "#{diff.current_name}", self, other
    end
  end
end


class DiffContext
  def initialize diff_name, size_limit
    @differences = []
    @path = []
    @left_stack = []
    @right_stack = []
    @limit_reached = false
    @diff_name = diff_name
    @size_limit = size_limit
  end
  
  attr_accessor :size_limit
  attr_reader :differences
  
  def show object
    "<#{object.inspect}>"
  end
  
  def path
    @path.join
  end
  
  def current_name
    "#{@diff_name}#{path}"
  end
    
  def report difference
    unless limit_reached?
      @differences << difference
    end
  end
    
  def report_unequal name, expected, actual
    report "#{name} was wrong. Expected #{show expected} got #{show actual}"
  end

  def report_extra name, unexpected
    report "#{name} was extra, had value #{show unexpected})"
  end

  def report_missing name, expected
    report "#{name} was missing, expected #{show expected}"
  end
  
  def report_circular sub_path, left, right
    report "#{current_name} was wrong. (#{@diff_name}#{sub_path}) expected, but was #{show right}"
  end
  
  def limit_reached?
    @differences.size >= @size_limit
  end
  
  def continue path_component, left, right
    return if limit_reached?
    
    @path.push path_component
    @left_stack.push left.object_id
    @right_stack.push right.object_id
    
    left_stack_index = @left_stack.index(left.object_id)
    
    if left_stack_index == @left_stack.size-1
      if left.diffs_with? right
        left.object_diff right, self
      else
        Object.instance_method(:object_diff).bind(left).call right, self
      end
    else
      if left.object_id != right.object_id && @right_stack.index(right.object_id) != left_stack_index
        sub_path = @path[0..left_stack_index].join
        report_circular sub_path, left, right
      end
    end
    
  ensure
    @path.pop
    @left_stack.pop
    @right_stack.pop
  end
end