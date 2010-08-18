# Copyright (c) 2010 ThoughtWorks Inc. (http://thoughtworks.com)
# Licenced under the Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0.txt)

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper'))

class GitRepositoryTest < Test::Unit::TestCase

  def test_empty_returns_true_when_no_changesets_in_repos
    repository = TestRepositoryFactory.create_repository_without_source_browser(nil)
    assert repository.empty?
  end

  def test_empty_returns_false_when_changesets_in_repos
    repository = TestRepositoryFactory.create_repository_without_source_browser('hello')
    assert !repository.empty?
  end

  def test_changeset_raises_error_when_repository_is_empty
    repository = TestRepositoryFactory.create_repository_without_source_browser(nil)
    begin
      changeset = repository.changeset('bogus')
      fail "should have failed"
    rescue StandardError => e
      assert_equal "Repository is empty!", e.message
    end
  end

  def test_changeset_raises_error_when_changeset_does_not_exist
    repository = TestRepositoryFactory.create_repository_without_source_browser('hello')
    begin
      changeset = repository.changeset('bogus')
      changeset.path
      fail "should have failed"
    rescue StandardError => e
      e.message.index("'bogus' is not a commit")
    end
  end

  def test_changeset_returns_changeset_when_it_exists
    repository = TestRepositoryFactory.create_repository_without_source_browser('hello')
    changeset = repository.changeset('23f49e83ecbd82c1dd4884a514a07bd992e102be')
    assert_equal '23f49e83ecbd82c1dd4884a514a07bd992e102be', changeset.commit_id
    assert_equal "mpm@selenic.com <mpm@selenic.com>", changeset.author
    assert_equal "Create a makefile", changeset.description
    assert_equal 'Fri Aug 26 08:21:28 UTC 2005', changeset.time.utc.to_s
  end

  def test_next_changesets_returns_empty_array_when_repository_empty
    repository = TestRepositoryFactory.create_repository_without_source_browser(nil)
    assert_equal [], repository.next_changesets(nil, 100)
  end

  def test_next_changesets_returns_all_changesets_when_repos_contains_fewer_changesets_than_limit
    repository = TestRepositoryFactory.create_repository_without_source_browser('hello')
    changesets = repository.next_changesets(nil, 100)
    assert_equal 5, changesets.size
    
    assert_equal (0..4).to_a, changesets.collect(&:number)

    sample_changeset = changesets[2]
    assert_equal 'b5ad6f93ec7252f8acd40a954451f3c25615a699', sample_changeset.commit_id
    assert_equal "Bryan O'Sullivan <bos@serpentine.com>", sample_changeset.author
    assert_equal "Introduce a typo into hello.c.", sample_changeset.description
    assert_equal 'Sun Aug 17 05:05:04 UTC 2008', sample_changeset.time.utc.to_s
  end
  
  def test_next_changesets_returns_changesets_from_zero_up_to_limit_when_repos_has_more_changesets_than_limit
    repository = TestRepositoryFactory.create_repository_without_source_browser('hello')
    
    changesets = repository.next_changesets(nil, 2)
    assert_equal 2, changesets.size
    assert_equal '2cf7a6a5e25f022ac4b18ce7165661cdc8177013', changesets[0].commit_id
    assert_equal '23f49e83ecbd82c1dd4884a514a07bd992e102be', changesets[1].commit_id
  end

  def test_next_changesets_returns_changesets_from_start_up_to_limit_when_repos_has_more_changesets_than_limit
    repository = TestRepositoryFactory.create_repository_without_source_browser('hello')
    youngest_in_project = OpenStruct.new(:number => 2, :identifier => 'b5ad6f93ec7252f8acd40a954451f3c25615a699')

    changesets = repository.next_changesets(youngest_in_project, 2)

    assert_equal [3, 4], changesets.collect(&:number)
    
    assert_equal 2, changesets.size
    assert_equal '8cf18930f5c6f457cec89011dfe45d8aff07d870', changesets[0].commit_id
    assert_equal '9f953d7cfd6eff8f79e5e383e7bca4b0cf89e13a', changesets[1].commit_id
  end


  def test_next_changesets_returns_empty_array_when_project_up_to_date_with_repository
    repository = TestRepositoryFactory.create_repository_without_source_browser('hello')
    youngest_in_project = '9f953d7cfd6eff8f79e5e383e7bca4b0cf89e13a'
    assert_equal [], repository.next_changesets(youngest_in_project, 100)
  end

  def test_can_build_changeset_with_chinese_commit_message
    repository = TestRepositoryFactory.create_repository_without_source_browser('chinese')
    unless "这是中文" == repository.changeset('head').description
      puts "\n\n======  WARNING ====="
      puts "we still have not figured out how to pull UTF-8"
      puts "string out of Java objects into Ruby-land! this"
      puts "plugin will not make you happy if your commit messages"
      puts "have non-ASCII chars!\n\n"
    end
  end

  def test_will_only_pull_once
    git_client = GitClient.new(nil, nil, nil)

    def git_client.pull
      @pull_count ||= 0
      @pull_count += 1
    end

    def git_client.pull_count
      @pull_count
    end

    repos = GitRepository.new(git_client, nil)
    repos.pull
    repos.pull
    assert_equal 1, git_client.pull_count
  end


  def test_node_throws_correct_error_on_bogus_revision
    repository = TestRepositoryFactory.create_repository_without_source_browser('hello')
    begin
      repository.node('', 300)
      fail "Exception was not raised due to bogus revision"
    rescue Repository::NoSuchRevisionError
      return
    end
  end

  # todo: introduce mocks, remove dependency on actual source browser(s)
  def test_node_for_head_and_tip_in_all_casings_will_return_tip_changeset
    repository, source_browser = TestRepositoryFactory.create_repository_with_source_browser('one_add')
    ['MASTER', 'master', 'head', 'HEAD'].each do |changeset|
      assert_equal 'e036967054a4f0ad0736c354053bcd27c2d6cb12', repository.node('', changeset).commit_id
    end
  end


  #
  # # todo: introduce mocks, remove dependency on actual source browser
  def test_node_throws_no_such_revision_error_when_uncached_changeset_requested
    repository, source_browser = TestRepositoryFactory.create_repository_with_source_browser('one_add')
    begin
      repository.node('', 1)
      fail("NoSuchRevisionError was not thrown!")
    rescue Repository::NoSuchRevisionError
      # this is good
    end
  end

end
