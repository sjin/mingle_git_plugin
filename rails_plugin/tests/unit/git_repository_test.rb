require File.expand_path File.join(File.dirname(__FILE__), '..', 'test_helper')

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
    changeset = repository.changeset('2')
    assert_equal 'ca1ec263c4dfe2b592436a1c894288fe552c8348', changeset.commit_id
    assert_equal "Ketan Padegaonkar <KetanPadegaonkar@gmail.com>", changeset.author
    assert_equal "added a hello world", changeset.description
    assert_equal 'Tue Mar 16 07:44:35 UTC 2010', changeset.time.utc.to_s
  end

  def test_next_changesets_returns_empty_array_when_repository_empty
    repository = TestRepositoryFactory.create_repository_without_source_browser(nil)
    assert_equal [], repository.next_changesets(nil, 100)
  end
  # 
  # def test_next_changesets_returns_all_changesets_when_repos_contains_fewer_changesets_than_limit
  #   repository = TestRepositoryFactory.create_repository_without_source_browser('hello')
  #   changesets = repository.next_changesets(nil, 100)
  #   assert_equal 5, changesets.size
  # 
  #   sample_changeset = changesets[2]
  #   assert_equal 'fef857204a0c58caefe249dda038316e856e896d', sample_changeset.changeset_identifier
  #   assert_equal 2, sample_changeset.revision_number
  #   assert_equal "Bryan O'Sullivan", sample_changeset.person
  #   assert_equal "Introduce a typo into hello.c.", sample_changeset.desc
  #   assert_equal 'Sat Aug 16 20:05:04 UTC 2008', sample_changeset.time.utc.to_s
  # end
  # 
  # def test_next_changesets_returns_changesets_from_zero_up_to_limit_when_repos_has_more_changesets_than_limit
  #   repository = TestRepositoryFactory.create_repository_without_source_browser('hello')
  #   changesets = repository.next_changesets(nil, 2)
  #   assert_equal 2, changesets.size
  #   assert_equal 0, changesets[0].number
  #   assert_equal 1, changesets[1].number
  # end
  # 
  # def test_next_changesets_returns_changesets_from_start_up_to_limit_when_repos_has_more_changesets_than_limit
  #   repository = TestRepositoryFactory.create_repository_without_source_browser('hello')
  #   youngest_in_project = OpenStruct.new(:number => 1)
  #   changesets = repository.next_changesets(youngest_in_project, 2)
  #   assert_equal 2, changesets.size
  #   assert_equal 2, changesets[0].number
  #   assert_equal 3, changesets[1].number
  # end
  # 
  # def test_next_changesets_returns_empty_array_when_project_up_to_date_with_repository
  #   repository = TestRepositoryFactory.create_repository_without_source_browser('hello')
  #   youngest_in_project = OpenStruct.new(:number => 4, :identifier => '2278160e78d4')
  #   assert_equal [], repository.next_changesets(youngest_in_project, 100)
  # end
  # 
  # def test_can_build_changeset_with_chinese_commit_message
  #   repository = TestRepositoryFactory.create_repository_without_source_browser('chinese')
  #   unless "这是中文" == repository.changeset(0).desc
  #     puts "\n\n======  WARNING ====="
  #     puts "we still have not figured out how to pull UTF-8"
  #     puts "string out of Java objects into Ruby-land! this"
  #     puts "plugin will not make you happy if your commit messages"
  #     puts "have non-ASCII chars!\n\n"
  #   end
  # end
  #   
  # def test_will_only_pull_once
  #   git_client = GitClient.new(nil)
  #   def git_client.pull
  #     @pull_count ||= 0
  #     @pull_count += 1
  #   end
  #   def git_client.pull_count
  #     @pull_count
  #   end
  #   repos = GitRepository.new(git_client, nil)
  #   repos.pull
  #   repos.pull
  #   assert_equal 1, git_client.pull_count
  # end
  # 
  # def test_node_throws_correct_error_on_bogus_revision
  #   repository = TestRepositoryFactory.create_repository_without_source_browser('hello')
  #   begin
  #     repository.node('', 300)
  #     fail "Exception was not raised due to bogus revision"
  #   rescue Repository::NoSuchRevisionError
  #     return
  #   end
  # end
  # 
  # # todo: introduce mocks, remove dependency on actual source browser(s)
  # def test_node_for_head_and_tip_in_all_casings_will_return_tip_changeset
  #   repository, source_browser = TestRepositoryFactory.create_repository_with_source_browser('one_add')
  #   source_browser.ensure_file_cache_synched_for(0)
  #   source_browser.ensure_file_cache_synched_for(1)
  # 
  #   ['tip', 'TIP', 'head', 'HEAD'].each do |changeset|
  #     assert_equal 1, repository.node('', changeset).changeset_number
  #   end
  # end
  # 
  # # todo: introduce mocks, remove dependency on actual source browser(s)
  # def test_node_uses_source_browser_tip_node_method_when_tip_is_requested
  #   repository, source_browser = TestRepositoryFactory.create_repository_with_source_browser('one_add')
  #   source_browser.ensure_file_cache_synched_for(0)
  #   source_browser.ensure_file_cache_synched_for(1)
  # 
  #   def source_browser.tip_node(path, likely_tip_number, likely_tip_identifier)
  #     @calling_node_now_ok = true
  #     super
  #   end
  #   def source_browser.node(path, number, identifier)
  #     raise "sorry, wrong method was used." unless @calling_node_now_ok
  #     super
  #   end
  #   assert_equal 1, repository.node('', 'tip').changeset_number
  # end
  # 
  # # todo: introduce mocks, remove dependency on actual source browser
  # def test_node_throws_no_such_revision_error_when_uncached_changeset_requested
  #   repository, source_browser = TestRepositoryFactory.create_repository_with_source_browser('one_add')
  #   begin
  #     repository.node('', 1)
  #     fail("NoSuchRevisionError was not thrown!")
  #   rescue Repository::NoSuchRevisionError
  #     # this is good
  #   end
  # end

end
