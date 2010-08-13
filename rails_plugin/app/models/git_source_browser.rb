# Copyright (c) 2010 ThoughtWorks Inc. (http://thoughtworks.com)
# Licenced under the Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0.txt)

class GitSourceBrowser
  def initialize(git_client, cache_path, mingle_revision_repository)
    @git_client = git_client
    @cache_path = cache_path
    @mingle_revision_repository = mingle_revision_repository
  end

  def ensure_file_cache_synched_for(changeset_identifier = nil)

  end

  def node(path, commit_id)
    DirNode.new(path, commit_id)
  end

  def head_node(path, commit_id)
    DirNode.new(path, commit_id)
  end
end


class DirNode

  attr_reader :path
  attr_reader :commit_id

  def initialize(path, commit_id)
    @path = path
    @commit_id = commit_id
  end

end