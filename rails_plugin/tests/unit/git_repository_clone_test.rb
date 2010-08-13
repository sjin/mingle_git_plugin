# Copyright (c) 2010 ThoughtWorks Inc. (http://thoughtworks.com)
# Licenced under the Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0.txt)

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper'))

class GitRepositoryCloneTest < Test::Unit::TestCase
  
  def test_pulls_on_next_changesets
    repository = RepositoryStub.new
    clone = GitRepositoryClone.new(repository)
    clone.next_revisions(nil, 100)
    assert repository.pulled?
  end
    
  class RepositoryStub
    
    def try_to_connect      
    end
        
    def next_revisions(skip_up_to, limit)
    end
    
    def pull
      @was_pulled = true
    end
    
    def pulled?
      @was_pulled
    end
    
    def ensure_local_clone
    end
    
  end
      
end