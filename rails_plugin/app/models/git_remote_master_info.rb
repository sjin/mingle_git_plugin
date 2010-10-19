class GitRemoteMasterInfo
  
  attr_reader :path, :log_safe_path
  
  def initialize(path, log_safe_path = nil)
    @path = path
    @log_safe_path = log_safe_path || path
  end
  
end