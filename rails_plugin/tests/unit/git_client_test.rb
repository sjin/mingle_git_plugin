# Copyright (c) 2010 ThoughtWorks Inc. (http://thoughtworks.com)
# Licenced under the Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0.txt)

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper'))

class GitClientTest < Test::Unit::TestCase
  
  def test_should_get_log_for_one_revision
    git_client = TestRepositoryFactory.create_client_from_bundle('hello')
    
    log_entry = git_client.log_for_rev('b5ad6f93ec7252f8acd40a954451f3c25615a699')
    assert_equal 'b5ad6f93ec7252f8acd40a954451f3c25615a699', log_entry[:commit_id]
    assert_equal "Bryan O'Sullivan <bos@serpentine.com>", log_entry[:author]
  end
  
  def test_should_get_log_entries_between_revision_range
    git_client = TestRepositoryFactory.create_client_from_bundle('hello')
    
    log_entries = git_client.log_for_revs('23f49e83ecbd82c1dd4884a514a07bd992e102be', '8cf18930f5c6f457cec89011dfe45d8aff07d870')
    
    assert_equal 2, log_entries.size
    assert_equal 'b5ad6f93ec7252f8acd40a954451f3c25615a699', log_entries.first[:commit_id]
    assert_equal '8cf18930f5c6f457cec89011dfe45d8aff07d870', log_entries.last[:commit_id]
    
    assert log_entries.first[:time] < log_entries.last[:time]
  end
  
  def test_can_use_head_for_getting_log_entries
    git_client = TestRepositoryFactory.create_client_from_bundle('hello')
    
    log_entries = git_client.log_for_revs('23f49e83ecbd82c1dd4884a514a07bd992e102be', 'head')
    
    assert_equal 3, log_entries.size
    assert_equal 'b5ad6f93ec7252f8acd40a954451f3c25615a699', log_entries.first[:commit_id]
    assert_equal '8cf18930f5c6f457cec89011dfe45d8aff07d870', log_entries.second[:commit_id]
    assert_equal '9f953d7cfd6eff8f79e5e383e7bca4b0cf89e13a', log_entries.last[:commit_id]    
    assert log_entries.first[:time] < log_entries.second[:time]
    assert log_entries.second[:time] < log_entries.last[:time]
  end
  
  def test_log_entries_are_empty_if_from_is_equal_to_to
    git_client = TestRepositoryFactory.create_client_from_bundle('hello')
    
    # head is 9f953
    assert_equal [], git_client.log_for_revs('9f953d7cfd6eff8f79e5e383e7bca4b0cf89e13a', 'head')
    assert_equal [], git_client.log_for_revs('b5ad6f93ec7252f8acd40a954451f3c25615a699', 'b5ad6f93ec7252f8acd40a954451f3c25615a699')
  end
  
  def test_get_log_from_first_revision
    git_client = TestRepositoryFactory.create_client_from_bundle('hello')
    
    log_entries = git_client.log_for_revs(nil, 'head')
    assert_equal 5, log_entries.size
    assert_equal '2cf7a6a5e25f022ac4b18ce7165661cdc8177013', log_entries.first[:commit_id]
    assert_equal '23f49e83ecbd82c1dd4884a514a07bd992e102be', log_entries.second[:commit_id]
    assert_equal '9f953d7cfd6eff8f79e5e383e7bca4b0cf89e13a', log_entries.last[:commit_id]
  end
  
  def test_get_log_with_limit
    git_client = TestRepositoryFactory.create_client_from_bundle('hello')
    
    log_entries = git_client.log_for_revs(nil, 'head', 2)
    assert_equal 2, log_entries.size
    assert_equal '2cf7a6a5e25f022ac4b18ce7165661cdc8177013', log_entries.first[:commit_id]
    assert_equal '23f49e83ecbd82c1dd4884a514a07bd992e102be', log_entries.second[:commit_id]
  end
  
  def test_can_build_log_entry_for_repo_with_single_revision
    git_client = TestRepositoryFactory.create_client_from_bundle('one_changeset')
    assert_equal '19df35cdb7d0219cb2b1adfe791d7b27bf14fda8', git_client.log_for_rev('head')[:commit_id]
  end
  
  def test_should_get_most_log_entry_about_path
    git_client = TestRepositoryFactory.create_client_from_bundle('hello')
    
    log_entries = git_client.log_for_path('9f953d7cfd6eff8f79e5e383e7bca4b0cf89e13a', 'hello.c')
    
    log_entry = log_entries.first
    assert_equal 1, log_entries.size
    assert_equal '9f953d7cfd6eff8f79e5e383e7bca4b0cf89e13a', log_entry[:commit_id]
    assert_equal "Bryan O'Sullivan <bos@serpentine.com>", log_entry[:author]
    assert_equal "Trim comments.", log_entry[:description]
    
    
    log_entries = git_client.log_for_path('8cf18930f5c6f457cec89011dfe45d8aff07d870', 'hello.c')
    
    log_entry = log_entries.first
    assert_equal 1, log_entries.size
    assert_equal 'b5ad6f93ec7252f8acd40a954451f3c25615a699', log_entry[:commit_id]
    assert_equal "Bryan O'Sullivan <bos@serpentine.com>", log_entry[:author]
    assert_equal "Introduce a typo into hello.c.", log_entry[:description]
  end
  
  def test_should_get_most_log_entry_about_multiple_path
    git_client = TestRepositoryFactory.create_client_from_bundle('hello')
    
    log_entries = git_client.log_for_path('9f953d7cfd6eff8f79e5e383e7bca4b0cf89e13a', 'hello.c', 'Makefile')
    assert_equal 2, log_entries.size
    
    log_entry = log_entries.first
    
    assert_equal '9f953d7cfd6eff8f79e5e383e7bca4b0cf89e13a', log_entry[:commit_id]
    assert_equal "Bryan O'Sullivan <bos@serpentine.com>", log_entry[:author]
    assert_equal "Trim comments.", log_entry[:description]
    
    log_entry = log_entries.last
    assert_equal '8cf18930f5c6f457cec89011dfe45d8aff07d870', log_entry[:commit_id]
    assert_equal "Bryan O'Sullivan <bos@serpentine.com>", log_entry[:author]
    assert_equal "Get make to generate the final binary from a .o file.", log_entry[:description]
  end
  
  def test_ls_tree_can_list_all_children_at_root_node
    git_client = TestRepositoryFactory.create_client_from_bundle("one_changeset_with_subdirs")
    
    assert_equal ['src', 'tests'].sort, git_client.ls_tree("", "master", true).keys.sort
    assert_equal ['src', 'tests'].sort, git_client.ls_tree("", "master", true).keys.sort
    assert_equal ['src/foo.rb'].sort, git_client.ls_tree("src", "head", true).keys.sort
  end
  
  def test_ls_tree_can_list_all_children_at_any_revision_node
    git_client = TestRepositoryFactory.create_client_from_bundle("hello")
    
    assert_equal ['hello.c', 'Makefile'].sort, git_client.ls_tree("", "9f953d7cfd6eff8f79e5e383e7bca4b0cf89e13a", true).keys.sort
    assert_equal ['hello.c'], git_client.ls_tree("", "2cf7a6a5e25f022ac4b18ce7165661cdc8177013", true).keys
  end
  
  def test_should_parse_commits_with_multi_line_comment
    git_client = TestRepositoryFactory.create_client_from_bundle("changeset_with_mutiline_commit_message")
    
    log_entries = git_client.log_for_revs(nil, 'head')
    assert_equal "this\n\n is a multi-line\n\ncommit", log_entries.first[:description]
  end
  
  def test_should_be_able_to_tell_whether_a_path_is_binary
    git_client = TestRepositoryFactory.create_client_from_bundle(nil)
    assert git_client.binary?("lib/foo.jar", nil)
    assert !git_client.binary?("src/foo.java", nil)
  end

end
