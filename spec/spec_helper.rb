require 'spec'
require File.dirname(__FILE__) + "/../lib/object_diff"

class String
  def to_regexp
    Regexp.new Regexp.escape(self)
  end
end