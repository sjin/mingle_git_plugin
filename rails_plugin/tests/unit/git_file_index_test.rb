# Copyright (c) 2010 ThoughtWorks Inc. (http://thoughtworks.com)
# Licenced under the Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0.txt)

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper'))

class GitFileIndexTest < Test::Unit::TestCase
  
  def test_should_be_able_to_find_latest_commit_for_paths_after_index_update
    index = GitFileIndex.new(TestRepositoryFactory.create_client_from_bundle("hello"))
    index.update
    assert_equal ["9f953d7cfd6eff8f79e5e383e7bca4b0cf89e13a", "8cf18930f5c6f457cec89011dfe45d8aff07d870"], 
      index.last_commit_id(['hello.c', 'Makefile'])
  end
  
  def test_can_use_a_before_commit_id_to_limit_the_lastes_commit_result
    index = GitFileIndex.new(TestRepositoryFactory.create_client_from_bundle("hello"))
    index.update
    assert_equal ["b5ad6f93ec7252f8acd40a954451f3c25615a699", "8cf18930f5c6f457cec89011dfe45d8aff07d870"], 
      index.last_commit_id(['hello.c', 'Makefile'], "8cf18930f5c6f457cec89011dfe45d8aff07d870")    
  end
  
  def test_can_before_commit_id_can_be_head_or_master
    index = GitFileIndex.new(TestRepositoryFactory.create_client_from_bundle("hello"))
    index.update
    assert_equal ["9f953d7cfd6eff8f79e5e383e7bca4b0cf89e13a", "8cf18930f5c6f457cec89011dfe45d8aff07d870"],
      index.last_commit_id(['hello.c', 'Makefile'], "head")
      
    assert_equal ["9f953d7cfd6eff8f79e5e383e7bca4b0cf89e13a", "8cf18930f5c6f457cec89011dfe45d8aff07d870"],
      index.last_commit_id(['hello.c', 'Makefile'], "master")
  end
  
  def test_get_last_commit_id_for_folders
    index = GitFileIndex.new(TestRepositoryFactory.create_client_from_bundle("one_changeset_with_subdirs"))
    index.update
    
    assert_equal ["58eec0e41c32000f90dfa7c8f18d0391b4165013", "58eec0e41c32000f90dfa7c8f18d0391b4165013"],
      index.last_commit_id(['src', 'tests'], "head")
  end
  
  # def test_benchmark_for_rails_repo
  #     file_list = Dir["/Users/ThoughtWorks/code/rails/*"].collect { |f| File.basename(f) }
  #     benchmark("http://github.com/rails/rails.git", file_list, "4a90ecb3adff8426aeddee0594c2b68f408e4af1")
  #   end
  #   
  #   def test_benchmark_for_git_repo
  #     file_list = Dir["/Users/ThoughtWorks/code/git/*"].collect { |f| File.basename(f) }
  #     benchmark("http://github.com/git/git.git", file_list, "c7e375de4228cdb86e2582e2eda7fa3a6f352fc2")    
  #   end
  
  def benchmark(master_path, file_list, revision )
    git_client = GitClient.new(master_path, "/Users/ThoughtWorks/code")

    file_list = Dir["/Users/ThoughtWorks/code/rails/*"].collect { |f| File.basename(f) }
    fi = GitFileIndex.new(git_client)
    Benchmark.bm(20) do |x|
      x.report('index building') do
        10.times { fi.clear; fi.update}
      end
      
      x.report('index updating (with empty)') do
        10.times { fi.update}
      end
      

      x.report('load latest revs') do
        10.times {lv = fi.last_commit_id(file_list, revision)}
      end
    end

  end
end
