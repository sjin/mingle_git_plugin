class GitRepository
      
  PER_FILE_PATCH_TRUNCATION_THRESHOLD = 1001
  
  def initialize(git_client, source_browser)
    @git_client = git_client
    @source_browser = source_browser
  end
  
   
  # *returns*: whether repository has any revisions
  def empty?
    @git_client.repository_empty?
  end
  
  # *returns*: the GitChangeset identified by treeish.  will work for commit_id, 
  # short identifier, long identifier. raises error if changset does not exist.
  def changeset(treeish)
    construct_changeset(@git_client.log_for_rev(treeish))
  end
  alias :revision :changeset

  # *returns*: the next _limit_ changesets, starting with the changeset beyond _skip_up_to_,
  # which is the last Revision that Mingle has cached. _skip_up_to_ is an actual Revision
  # object from the Mingle model.
  def next_changesets(skip_up_to, limit)
    return [] if empty?    
    tip_number, tip_identifier, the_rest = @git_client.log_for_rev('tip')
    return [] if skip_up_to && skip_up_to.number.to_i == tip_number.to_i
    from = skip_up_to.nil? ? 0 : skip_up_to.number + 1
    to = [from + limit - 1, tip_number.to_i].min
    log_entries = @git_client.log_for_revs(from, to)
    log_entries.map{|log_entry| construct_changeset(*log_entry)}
  end
  #   alias :next_revisions :next_changesets
  #   
  #   # *returns* the GitFileNode or GitDirNode for _path_ for consumption by the source browser pages
  #   # todo: need to co-ordinate with Mingle guys to remove dependency on Repository::NoSuchRevisionError
  #   def node(path, changeset_identifier = 'tip')
  #     changeset_identifier = 'tip' if ['tip', 'head'].any?{|tip_id| tip_id == changeset_identifier.to_s.downcase}
  #         
  #     begin
  #       proper_changeset = changeset(changeset_identifier)
  #     rescue StandardError => e 
  #       ActiveRecord::Base.logger.warn( %{
  #         GitRepository unable to find changeset #{changeset_identifier}: #{e}.
  #         This could be OK if the #{changeset_identifier} is indeed a bogus changeset.
  #       })     
  #       raise Repository::NoSuchRevisionError.new
  #     end
  #     
  #     begin
  #       if changeset_identifier == 'tip'
  #         @source_browser.tip_node(path, proper_changeset.number, proper_changeset.identifier)
  #       else
  #         @source_browser.node(path, proper_changeset.number, proper_changeset.identifier)
  #       end
  #     rescue StandardError => e
  #       ActiveRecord::Base.logger.warn(%{
  #         GitRepository unable to build node for changeset #{changeset_identifier}. 
  #         This could be OK if the #{changeset_identifier} is indeed a bogus changeset.
  #         Otherwise, the changeset is likely still being cached by Mingle.
  #         This is quite likely in the case of the initial caching of a large Git repository.
  #       })
  #       raise Repository::NoSuchRevisionError.new
  #     end
  #   end
  #   
  #   #:nodoc:
  #   def git_patch_for(changeset, truncation_threshold = PER_FILE_PATCH_TRUNCATION_THRESHOLD)
  #     git_patch = GitGitPatch.new(changeset.identifier, self, truncation_threshold)
  #     @git_client.git_patch_for(changeset.identifier, git_patch)
  #     git_patch
  #   end
  #   
  #   #:nodoc:
  #   def files_in(changeset_identifier)
  #     @git_client.files_in(changeset_identifier)
  #   end
  #     
  #   #:nodoc:
  #   def dels_in(changeset_identifier)
  #     @git_client.dels_in(changeset_identifier)
  #   end
  # 
  #   #:nodoc:
  #   def binary?(path, changeset_identifier)
  #     @git_client.binary?(path, changeset_identifier)
  #   end
  #     
  #   #:nodoc:
  #   def pull
  #     return if @pulled
  #     @git_client.pull
  #     @pulled = true
  #   end 
  #   
  #   #:nodoc:
  #   def ensure_local_clone
  #     @git_client.ensure_local_clone
  #   end   
  # 
  #   def try_to_connect
  #     @git_client.try_to_connect
  #   end
  #     
    #:nodoc:
    def construct_changeset(log_entry)
      GitChangeset.new(log_entry, self)
    end 
    
end

