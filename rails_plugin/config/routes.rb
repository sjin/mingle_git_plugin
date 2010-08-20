# Copyright (c) 2010 ThoughtWorks Inc. (http://thoughtworks.com)
# Licenced under the Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0.txt)

ActionController::Routing::Routes.draw do |map|
  map.with_options :controller => 'changesets' do |changesets|
    changesets.changeset 'projects/:project_id/changesets/:rev', :action => 'show'
  end
  
  map.with_options :controller => 'git_source' do |controller|
    controller.connect 'projects/:project_id/git_source/load_latest_info', :action => 'load_latest_info'
  end
end