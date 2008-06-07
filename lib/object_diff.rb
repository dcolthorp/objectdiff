require 'ostruct'

Dir[File.dirname(__FILE__) + "/diff_strategies/*.rb"].each do |strategy|
  require strategy
end

class ObjectDiff
  DEFAULT_SIZE_LIMIT = 20

  def initialize  diff_name="actual", size_limit=DEFAULT_SIZE_LIMIT
    @context = DiffContext.new diff_name, size_limit
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
  
  def limit_reached?
    @limit_reached
  end
  
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
    @differences << difference
  end
    
  def report_unequal name, expected, actual
    report "#{name} was wrong. Expected #{show expected} got #{show actual}"
  end

  def report_extra name, unexpected
    report "#{name} should not have been present, but was #{show unexpected})"
  end

  def report_missing name, expected
    report "#{name} was not present and should have been #{show expected}"
  end
  
  def report_circular sub_path, left, right
    report "#{current_name} was wrong. (#{@diff_name}#{sub_path}) expected, but was #{show right}"
  end
  
  def should_continue?
    if @differences.size >= @size_limit
      @limit_reached = true
      false
    else
      true
    end
  end
  
  def continue path_component, left, right
    return unless should_continue?
    
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