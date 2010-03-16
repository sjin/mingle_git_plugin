
# {SCM_NAME}RepositoryClone manages when to pull from master to clone. Behavior pulled into
# decorator as it makes tests much faster and also keeps GitRepository more single-minded.
class GitRepositoryClone
    
  def initialize(repository)
    @repository = repository
    @repository.try_to_connect
  end

  def method_missing(method, *args)
    @repository.ensure_local_clone
    @repository.pull if (method.to_sym == :next_revisions) 
    @repository.send(method, *args)
  end
    
end

