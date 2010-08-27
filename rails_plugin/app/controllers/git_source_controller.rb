# Copyright (c) 2010 ThoughtWorks Inc. (http://thoughtworks.com)
# Licenced under the Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0.txt)

class GitSourceController < ApplicationController
  
  def load_latest_info
    revisions = @project.revisions.find(:all, :conditions => ["identifier in (?)", params[:commits]])
    render(:update) do |page|
      page.select("#svn_browser td.to-be-replaced").each do |element|
        element.innerHTML = "Still caching..."
      end
      
      revisions.each do |rev|
        page.select("#svn_browser td.#{rev.identifier}").each do |element|
          page.replace(element, :partial => 'node_table_row_with_detail', :locals => { :revision => rev })
        end
      end
    end
  end
end
