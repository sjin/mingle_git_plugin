# Copyright (c) 2010 ThoughtWorks Inc. (http://thoughtworks.com)
# Licenced under the Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0.txt)

class GitRepositoryClone
    
  def initialize(repository, clone_dir, project, retry_errored_connect = false)
    @repository = repository
    @clone_dir = clone_dir
    
    if File.exist?(error_file) && !retry_errored_connect
      raise StandardError.new(
        %{Mingle cannot connect to the Git repository for project #{project.identifier}. 
        The details of the problem are in the file at #{clone_dir}/error.txt})
    end
  end

  def method_missing(method, *args)
    begin
      @repository.ensure_local_clone
      @repository.pull if (method.to_sym == :next_revisions) 
      delete_error_file 
    rescue StandardError => e
      write_error_file(e)
      raise e
    end

    @repository.send(method, *args)
  end
    
  private 
  
  def error_file
    "#{@clone_dir}/error.txt"
  end
  
  def delete_error_file
    rm_f(error_file)
  end
  
  def write_error_file(e)    
    mkdir_p(File.dirname(error_file))
    File.open(error_file, 'w') do |file|
      file << "Message:\n#{e.message}\n\nTrace:\n"
      file << e.backtrace.join("\n")
    end
  end
  
end
