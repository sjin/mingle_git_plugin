# Copyright (c) 2010 ThoughtWorks Inc. (http://thoughtworks.com)
# Licenced under the Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0.txt)

class GitSourceController < ApplicationController
  
  def load_latest_info
    # profile do
    parent = @project.repository_node(params[:path], params[:commit_id])
    render(:update) do |page|
      parent.children.each do |node|
        node.load_last_log_entry
        page.replace_html "node_#{node.git_object_id}", :partial => 'node_table_row_with_detail', :locals => {:node => node, :view_revision => params[:commit_id] }
      end
    end
    # end
  end
end
