# Copyright (c) 2010 ThoughtWorks Inc. (http://thoughtworks.com)
# Licenced under the Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0.txt)

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper'))

class GitClientTest < Test::Unit::TestCase
  
  # GitClient.logging_enabled = true
      
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
  
  def test_case_name
    git_client = TestRepositoryFactory.create_client_from_bundle('hello')
    
    log_entries = git_client.log_for_revs(nil, 'head')
    assert_equal 5, log_entries.size
    assert_equal '2cf7a6a5e25f022ac4b18ce7165661cdc8177013', log_entries.first[:commit_id]
    assert_equal '9f953d7cfd6eff8f79e5e383e7bca4b0cf89e13a', log_entries.last[:commit_id]
  end
  
  def test_can_build_log_entry_for_repo_with_single_revision
    git_client = TestRepositoryFactory.create_client_from_bundle('one_changeset')
    assert_equal '19df35cdb7d0219cb2b1adfe791d7b27bf14fda8', git_client.log_for_rev('head')[:commit_id]
  end
end
