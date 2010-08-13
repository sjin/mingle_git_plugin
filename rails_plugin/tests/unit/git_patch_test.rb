require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class GitPatchTest < Test::Unit::TestCase

  def test_can_split_into_changes
    git_patch = patch_from_snippet(GitPatchSnippets::TWO_ADDS)
    assert_equal 2, git_patch.changes.size
  end

  def test_change_detail_on_add_non_binary_file
    change = first_change_from_snippet(GitPatchSnippets::TWO_ADDS)
    assert_equal 'person.rb', change.path
    assert_equal [:added], change.change_type
    assert !change.binary?
  end

  def test_change_detail_on_delete_non_binary_file
    change = first_change_from_snippet(GitPatchSnippets::DELETE)
    assert_equal 'salary.rb', change.path
    assert_equal [:deleted], change.change_type
    assert !change.binary?
  end

  def test_change_detail_on_modify_non_binary_file
    change = first_change_from_snippet(GitPatchSnippets::MODIFY)
    assert_equal 'person.rb', change.path
    assert_equal [:modified], change.change_type
    assert !change.binary?
  end

  def test_change_detail_on_rename_non_binary_file_with_modify
    change = first_change_from_snippet(GitPatchSnippets::RENAME_WITH_MODIFY)
    assert_equal 'todo.rb', change.path
    assert_equal 'task.rb', change.renamed_from_path
    assert_equal [:renamed, :modified], change.change_type
    assert !change.binary?
  end

  def test_change_detail_on_rename_non_binary_file_without_modify
    # rename w/o mods can only be tested directly against repsitory
    repository = TestRepositoryFactory.create_repository_without_source_browser('renames')
    git_patch = repository.git_patch_for(repository.changeset('a34dcd4c877a6277c9c956a5e6a0e808ebdab2c6'))
    change = git_patch.changes.last
    assert_equal 'plain.txt', change.path
    assert_equal 'plain-moved.txt', change.renamed_from_path
    assert_equal [:renamed], change.change_type
    assert !change.binary?
  end

  #todo (low): create bundle to avoid stub
  def test_change_path_when_path_itself_looks_like_the_diff_format
    repos_stub = Object.new
    def repos_stub.binary?(path, changeset)
      false
    end
    change = first_change_from_snippet(GitPatchSnippets::FUNKY_PATHS, repos_stub)
    assert_equal 'foo/n o o b/README.txt', change.path
  end

  def test_change_detail_on_add_binary_file
    change = first_change_from_snippet(GitPatchSnippets::BINARY_ADD)
    assert_equal 'image.png', change.path
    assert_equal [:added], change.change_type
    assert change.binary?
  end

  def test_change_detail_on_delete_binary_file
    change = first_change_from_snippet(GitPatchSnippets::BINARY_DELETE)
    assert_equal 'image.png', change.path
    assert_equal [:deleted], change.change_type
    assert change.binary?
  end

  def test_change_detail_on_modify_binary_file
    change = first_change_from_snippet(GitPatchSnippets::BINARY_MODIFY)
    assert_equal 'image.png', change.path
    assert_equal [:modified], change.change_type
    assert change.binary?
  end

  def test_change_detail_on_rename_binary_file_with_modify
    change = first_change_from_snippet(GitPatchSnippets::BINARY_RENAME_WITH_MODIFY)
    assert_equal 'picture.png', change.path
    assert_equal 'image.png', change.renamed_from_path
    assert_equal [:renamed, :modified], change.change_type
    assert change.binary?
  end

  def test_change_detail_on_rename_binary_file_without_modify
    # rename w/o mods should only be tested directly against repsitory
    repository = TestRepositoryFactory.create_repository_without_source_browser('renames')
    git_patch = repository.git_patch_for(repository.changeset('a34dcd4c877a6277c9c956a5e6a0e808ebdab2c6'))
    change = git_patch.changes.first
    assert_equal 'binary-moved.png', change.path
    assert_equal 'binary.png', change.renamed_from_path
    assert_equal [:renamed], change.change_type
    assert change.binary?
  end

  def test_change_detail_on_copy_non_binary_file
    change = first_change_from_snippet(GitPatchSnippets::COPY)
    assert_equal 'tags/thought_viscera-3.6/README', change.path
    assert_equal [:added], change.change_type
    assert !change.binary?
  end

  # no idea how Cruise rev 0 got in this state, but we need to handle it...
  def test_changeset_with_no_changes_simply_returns_empty_list_of_changes
    repository = TestRepositoryFactory.create_repository_without_source_browser('empty_rev')
    git_patch = repository.git_patch_for(repository.changeset('0'))
    assert git_patch.changes.empty?
  end

  def test_changes_are_truncated_when_diff_too_large
    repository = TestRepositoryFactory.create_repository_without_source_browser('big_diff')
    git_patch = repository.git_patch_for(repository.changeset('1'), 10)
    assert git_patch.changes[0].truncated?
    assert_equal git_patch.changes[0].lines.size, 10
  end

  def test_changes_are_not_truncated_when_diff_is_exactly_at_limit
    repository = TestRepositoryFactory.create_repository_without_source_browser('big_diff')
    git_patch = repository.git_patch_for(repository.changeset('1'), 35)
    assert !git_patch.changes[0].truncated?
    assert_equal git_patch.changes[0].lines.size, 35
  end

  def test_changes_are_not_truncated_when_diff_is_below_limit
    repository = TestRepositoryFactory.create_repository_without_source_browser('big_diff')
    git_patch = repository.git_patch_for(repository.changeset('1'), 100)
    assert !git_patch.changes[0].truncated?
    assert_equal git_patch.changes[0].lines.size, 35
  end

  def first_change_from_snippet(snippet_text, repos_stub = nil)
    patch_from_snippet(snippet_text, repos_stub).changes.first
  end

  def patch_from_snippet(snippet_text, repos_stub = nil)
    patch = GitPatch.new(nil, repos_stub)
    StringIO.new(snippet_text).each do |line|
      patch.add_line(line)
    end
    patch.done_adding_lines
    patch
  end

end