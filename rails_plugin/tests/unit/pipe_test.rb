# Copyright (c) 2010 ThoughtWorks Inc. (http://thoughtworks.com)
# Licenced under the Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0.txt)

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper'))

class PipeTest < Test::Unit::TestCase
  
  def test_convert_entries_to_array
    pipe = Pipe.new(100)
    pipe << 'foo'
    pipe << 'bar'
    assert_equal ['foo', 'bar'], pipe.to_a
  end
  
  def test_replace_the_oldest_element_when_exceed_limit
    pipe = Pipe.new(2)
    pipe << :a
    pipe << :b
    pipe << :c
    
    assert_equal [:b, :c], pipe.to_a
  end
  
end