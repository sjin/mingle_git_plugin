# Copyright (c) 2010 ThoughtWorks Inc. (http://thoughtworks.com)
# Licenced under the Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0.txt)

require 'pstore'

class GitFileIndex
  attr_reader :commits, :files
  
  def initialize(git_client)
    @git_client = git_client
  end
  
  def last_commit_id(pathes, before_commit_id=nil)
    load_from_disk
    
    before_commit_index =  @commits.index(before_commit_id) || (@commits.size - 1)
    pathes.collect do |path|
      index = commit_list_for(path).reverse.detect { |i| i <= before_commit_index }
      index && @commits[index]
    end
  end
  
  def update
    load_from_disk
    need_update = false
    @git_client.git("log --pretty=oneline --name-only --reverse #{update_window}") do |stdout|
      current_commit = nil
      current_commit_index = @commits.size - 1
      
      stdout.each_line do |line|
        if /^(\w{40})/.match(line)
          current_commit = $1
          current_commit_index += 1
          @commits.push(current_commit)
          need_update = true
        else
          file_name = line.chomp
          tree = ""
          File.dirname(file_name).split('/').each do |part|
            next if part == '.'
            tree += part + '/'
            commit_list_for(tree).push(current_commit_index)
          end

          commit_list_for(file_name).push(current_commit_index)
        end        
      end
    end
    
    save_to_disk if need_update
  end
  
  def clear
    FileUtils.rm_rf(pstore_file)
  end

  private
  
  def pstore
    @pstore ||= PStore.new(pstore_file)
  end
  
  def pstore_file
    File.join(@git_client.clone_path, "file-index.pstore")
  end
  
  def update_window
    @commits.empty? ? "--all" : "#{commits.last}..head"
  end
  
  def commit_list_for(path)
    @files[path] ||= []
  end
  
  def save_to_disk
    pstore.transaction do
      pstore[:commits] = @commits
      pstore[:files] = @files
    end
  end
  
  def load_from_disk
    pstore.transaction(true) do
      @commits = pstore[:commits] || []
      @files = pstore[:files] || {}
    end
  end
end