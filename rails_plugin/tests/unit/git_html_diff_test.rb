# Copyright (c) 2010 ThoughtWorks Inc. (http://thoughtworks.com)
# Licenced under the Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0.txt)

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper'))

class GitHtmlDiffTest < Test::Unit::TestCase

  def test_truncated_change_is_reflected_in_html
    repository = TestRepositoryFactory.create_repository_without_source_browser('big_diff')
    git_patch = repository.git_patch_for(repository.changeset('e896ee5065a3e7f9813c6fef3e1cc42262965a78'), 10)
    diff = GitHtmlDiff.new(git_patch.changes.first, 1)
    assert diff.content.index("diff truncated")
  end

  def test_content_does_not_show_truncation_message_when_not_needed
    repository = TestRepositoryFactory.create_repository_without_source_browser('big_diff')
    git_patch = repository.git_patch_for(repository.changeset('e896ee5065a3e7f9813c6fef3e1cc42262965a78'), 100)
    diff = GitHtmlDiff.new(git_patch.changes.first, 1)
    assert !diff.content.index("diff truncated")
  end

end
