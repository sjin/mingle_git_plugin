# Copyright (c) 2010 ThoughtWorks Inc. (http://thoughtworks.com)
# Licenced under the Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0.txt)

class Pipe
  
  def initialize(limit)
    @limit = limit
    @array = []
  end
  
  def << (element)
    @array << element
    @array.shift if @array.size > @limit
  end
  
  def to_a
    @array.to_a
  end
  
end