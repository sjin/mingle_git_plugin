# Copyright (c) 2010 ThoughtWorks Inc. (http://thoughtworks.com)
# Licenced under the Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0.txt)

class GitRepositoryClone
    
  def initialize(repository)
    @repository = repository
    @repository.try_to_connect
  end

  def method_missing(method, *args)
    @repository.ensure_local_clone
    @repository.pull if (method.to_sym == :next_revisions) 
    @repository.send(method, *args)
  end
    
end

