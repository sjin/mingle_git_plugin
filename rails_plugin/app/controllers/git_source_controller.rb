# Copyright (c) 2010 ThoughtWorks Inc. (http://thoughtworks.com)
# Licenced under the Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0.txt)

class GitSourceController < ApplicationController
  
  def load_latest_info
    commit_id = params[:commit_id]
    
    nodes = params[:nodes].collect do |path, git_object_id|
      node = @project.repository_node(path, commit_id)
      node.git_object_id = git_object_id
      node
    end
    
    render(:update) do |page|
      nodes.each do |node|
        page.replace_html "node_#{node.git_object_id}", :partial => 'node_table_row_with_detail', :locals => {:node => node, :view_revision => commit_id }
      end
    end
  end
end
