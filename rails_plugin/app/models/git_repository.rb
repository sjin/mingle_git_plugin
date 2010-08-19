# Copyright (c) 2010 ThoughtWorks Inc. (http://thoughtworks.com)
# Licenced under the Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0.txt)

class GitRepository

  PER_FILE_PATCH_TRUNCATION_THRESHOLD = 1001

  def initialize(git_client, source_browser)
    @git_client = git_client
    @source_browser = source_browser
  end

  def empty?
    @git_client.repository_empty?
  end

  def changeset(commit_id)
    if commit_id && commit_id !~ /^[a-zA-Z0-9]{40}$/ && !['head', 'master'].include?(commit_id.downcase) && Project.current
      rev = Project.current.revisions.find_by_number(commit_id)
      commit_id = rev.identifier if rev
    end
      
    construct_changeset(@git_client.log_for_rev(commit_id))
  end

  alias :revision :changeset

  def next_changesets(skip_up_to, limit)
    return [] if empty?
    head = @git_client.log_for_rev('head')
    return [] if skip_up_to && skip_up_to == head[:commit_id]
    
    to = 'head'
    from = skip_up_to ? skip_up_to.identifier : nil

    log_entries = @git_client.log_for_revs(from, to, limit)

    last_number = skip_up_to ? skip_up_to.number+1 : 0

    log_entries.map do |log_entry|
      changeset = construct_changeset(log_entry)
      changeset.number = last_number
      last_number += 1
      changeset
    end
  end

  alias :next_revisions :next_changesets

  def node(path, changeset_identifier = 'head')
    changeset_identifier = changeset_identifier.to_s.downcase

    begin
      proper_changeset = changeset(changeset_identifier)
    rescue StandardError => e
      ActiveRecord::Base.logger.warn( %{
           GitRepository unable to find changeset #{changeset_identifier}: #{e}.
           This could be OK if the #{changeset_identifier} is indeed a bogus changeset.
         })
      raise Repository::NoSuchRevisionError.new
    end

    begin
      @source_browser.node(path, proper_changeset.commit_id)
    rescue StandardError => e
      ActiveRecord::Base.logger.warn(%{
           GitRepository unable to build node for changeset #{changeset_identifier}.
           This could be OK if the #{changeset_identifier} is indeed a bogus changeset.
           Otherwise, the changeset is likely still being cached by Mingle.
           This is quite likely in the case of the initial caching of a large Git repository.
         })
      raise Repository::NoSuchRevisionError.new(e)
    end
  end

  def git_patch_for(changeset, truncation_threshold = PER_FILE_PATCH_TRUNCATION_THRESHOLD)
    git_patch = GitPatch.new(changeset.commit_id, self, truncation_threshold)
    @git_client.git_patch_for(changeset.commit_id, git_patch)
    git_patch
  end

  def binary?(path, commit_id)
    @git_client.binary?(path, commit_id)
  end
     
  def pull
    return if @pulled
    @git_client.pull
    @pulled = true
  end

  #:nodoc:
  def ensure_local_clone
    @git_client.ensure_local_clone
  end
  
  def try_to_connect
    @git_client.try_to_connect
  end

  def construct_changeset(log_entry)
    GitChangeset.new(log_entry, self)
  end

end

