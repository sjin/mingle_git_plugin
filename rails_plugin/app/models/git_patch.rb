# Copyright (c) 2010 ThoughtWorks Inc. (http://thoughtworks.com)
# Licenced under the Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0.txt)

require 'git_change'
class GitPatch
  def initialize(commit_id, repository, truncation_threshold = nil)
    @commit_id = commit_id
    @repository = repository
    @changes = []
    @current_change_lines = []
    @truncation_threshold = truncation_threshold
  end

  def changes
    @changes
  end

  def done_adding_lines
    add_current_change
  end

  def add_line(line)
    if (line =~ /^diff --git/ && @current_change_lines.size > 0)
      add_current_change
    end

    if @truncation_threshold && @current_change_lines.size == @truncation_threshold
      @current_change_truncated = true
    end

    if @truncation_threshold.nil? || @current_change_lines.size < @truncation_threshold
      @current_change_lines << line
    end
  end

  def add_current_change
    #some repositories in the wild have empty changesets, so we only add if we have change lines
    if @current_change_lines.size > 1
      @changes << GitGitChange::Factory.construct(
              @commit_id,
              @current_change_lines,
              @repository,
              @current_change_truncated
      )
    end
    @current_change_truncated = false
    @current_change_lines = []
  end
end