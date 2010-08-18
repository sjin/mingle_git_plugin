# Copyright (c) 2010 ThoughtWorks Inc. (http://thoughtworks.com)
# Licenced under the Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0.txt)

class GitSourceBrowser
  def initialize(git_client, mingle_revision_repository)
    @git_client = git_client
    @mingle_revision_repository = mingle_revision_repository
  end


  def node(path, commit_id)
    is_dir = @git_client.dir?(path, commit_id)
    last_log_entry = @git_client.log_for_path(commit_id, path).first
    is_dir ? DirNode.new(path, commit_id, @git_client, last_log_entry) : FileNode.new(path, commit_id, @git_client, last_log_entry)
  end
  
  private
  
  def dir?(tree)
    tree.size == 1 && tree.first[:type] == :tree
  end
  
  def create_node(child, path, commit_id)
    if (child[:type] == :tree)
      DirNode.new(path, commit_id, nil)
    else
      FileNode.new(path, commit_id, child[:object_id], @git_client)
    end
  end
  
end

class Node

  attr_reader :path
  attr_reader :commit_id
  attr_reader :git_client

  def initialize(path, commit_id, git_client, last_log_entry)
    @path = path.gsub(/\/$/, '')
    @commit_id = commit_id
    @git_client = git_client
    @last_log_entry = last_log_entry
  end
  
  def name
    path.split('/').last
  end
  
  def display_path
    path
  end
  
  def path_components
    path.split('/')
  end
  
  def most_recent_committer
    @last_log_entry[:author]
  end
  
  def most_recent_commit_time
    @last_log_entry[:time]
  end
  
  def most_recent_commit_desc
    @last_log_entry[:description]
  end
  
  def most_recent_changeset_identifier
    @last_log_entry[:commit_id]
  end
  
  def parent_path_components
    path_components[0..-2]
  end
  
  def parent_display_path
    parent_path_components.join('/')
  end
end

class DirNode < Node

  def children
    git_client.ls_tree(path, commit_id, true).collect do |child_path, desc|
      desc[:type] == :tree ? DirNode.new(child_path, commit_id, git_client, desc[:last_changeset]) : FileNode.new(child_path, commit_id, git_client, desc[:last_changeset])
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
    false
  end
  
  private
  def git_object_id
    tree = git_client.ls_tree(path, commit_id)
    tree[path][:object_id]
  end
end