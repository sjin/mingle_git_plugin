# Copyright (c) 2010 ThoughtWorks Inc. (http://thoughtworks.com)
# Licenced under the Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0.txt)

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper'))

class GitRepositoryCloneTest < Test::Unit::TestCase
  
  def setup
    @repository = RepositoryStub.new
    @clone_dir = "#{TMP_DIR}/#{ActiveSupport::SecureRandom.hex(32)}"
    @clone = GitRepositoryClone.new(@repository, @clone_dir, Project.new)
  end
    
  def test_pulls_on_next_changesets
    @clone.next_revisions(nil, 100)
    assert @repository.pulled?
  end
  
  def test_cannot_construct_if_error_file_exists
    mkdir_p(@clone_dir)
    error_file = "#{@clone_dir}/error.txt"
    touch(error_file)
    
    begin
      GitRepositoryClone.new(@repository, @clone_dir, Project.new)
      fail "Should not have been able to construct!"
    rescue StandardError => e
      raise e unless e.message.index("Mingle cannot connect")
    end
  end
  
  def test_can_construct_if_error_file_exists_when_retry_specified
    mkdir_p(@clone_dir)
    error_file = "#{@clone_dir}/error.txt"
    touch(error_file)
    
    GitRepositoryClone.new(@repository, @clone_dir, Project.new, true)
  end
  
  def test_writes_error_file_when_clone_fails
    def @repository.ensure_local_clone
      raise StandardError.new("Bad credentials!")
    end
    
    begin
      @clone.ensure_local_clone
    rescue StandardError => expected_error
    end
    
    assert_error_file_exists
  end
  
  def test_deletes_error_file_when_clone_succeeds
    mkdir_p(@clone_dir)
    error_file = "#{@clone_dir}/error.txt"
    touch(error_file)
    
    @clone.ensure_local_clone
    assert_error_file_does_not_exist
  end
  
  def test_writes_error_file_when_pull_fails
    def @repository.pull
      raise StandardError.new("Bad credentials!")
    end
    
    begin
      @clone.next_revisions(nil, 100)
    rescue StandardError => expected_error
    end
    
    assert_error_file_exists
  end
  
  def test_deletes_error_file_when_pull_succeeds
    mkdir_p(@clone_dir)
    error_file = "#{@clone_dir}/error.txt"
    touch(error_file)
    
    @clone.next_revisions(nil, 100)
    assert_error_file_does_not_exist
  end
  
  def assert_error_file_exists
    assert File.exist?("#{@clone_dir}/error.txt")
  end
  
  def assert_error_file_does_not_exist
    assert !File.exist?("#{@clone_dir}/error.txt")
  end
    
  class RepositoryStub
            
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
