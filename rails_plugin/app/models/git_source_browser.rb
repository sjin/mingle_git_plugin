# Copyright (c) 2010 ThoughtWorks Inc. (http://thoughtworks.com)
# Licenced under the Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0.txt)

class GitSourceBrowser
  
  def initialize(git_client)
    @git_client = git_client
  end

  def node(path, commit_id)
    is_dir = @git_client.dir?(path, commit_id)
    is_dir ? DirNode.new(path, commit_id, @git_client) : FileNode.new(path, commit_id, @git_client)
  end
 
end

class Node

  attr_reader :path, :commit_id, :git_client
  
  alias :display_path :path

  def initialize(path, commit_id, git_client, git_object_id=nil, last_log_entry=nil)
    @path = path.gsub(/\/$/, '')
    @commit_id = commit_id
    @git_client = git_client
    @git_object_id = git_object_id
    @last_log_entry = last_log_entry || {} 
  end
  
  def git_object_id
    @git_object_id ||= @git_client.ls_tree(path, commit_id)[path][:object_id]
  end
  
  def last_log_entry_loaded?
    @last_log_entry.empty?
  end
  
  def last_log_entry
    @last_log_entry
  end
  
  def name
    path.split('/').last
  end
  
  def path_components
    path.split('/')
  end
  
  def most_recent_committer
    last_log_entry[:author]
  end
  
  def most_recent_commit_time
    last_log_entry[:time]
  end
  
  def most_recent_commit_desc
    last_log_entry[:description]
  end
  
  def most_recent_changeset_identifier
    last_log_entry[:commit_id]
  end
  
  def parent_path_components
    path_components[0..-2]
  end
  
  def parent_display_path
    parent_path_components.join('/')
  end
  
end

class DirNode < Node

  def children(with_last_rev=false)    
    git_client.ls_tree(path, commit_id, true, with_last_rev).collect do |child_path, desc|
      node = desc[:type] == :tree ? DirNode.new(child_path, commit_id, git_client, desc[:object_id], desc[:last_rev]) : FileNode.new(child_path, commit_id, git_client, desc[:object_id], desc[:last_rev])
    end
  end
  
  def dir?
    true
  end
    
  def root_node?
    path.empty?
  end
  
end

class FileNode < Node
  
  def file_contents(io)
    @git_client.cat(path, git_object_id, io)
  end
  
  def dir?
    false
  end
  
  def binary?
    @git_client.binary?(path, commit_id)
  end
  
end