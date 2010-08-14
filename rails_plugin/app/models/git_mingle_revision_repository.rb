# Copyright (c) 2010 ThoughtWorks Inc. (http://thoughtworks.com)
# Licenced under the Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0.txt)

class GitMingleRevisionRepository
  
  def initialize(project)
    @project = project
  end
  
  def sew_in_most_recent_changeset_data_from_mingle(children)
    mingle_revisions = @project.revisions.find_all_by_identifier(children.map(&:most_recent_changeset_identifier))
    mingle_revisions_by_identifier = {}
    mingle_revisions.each{|mrev| mingle_revisions_by_identifier[mrev.identifier] = mrev}
    children.each do |child|
      most_recent_revision = mingle_revisions_by_identifier[child.most_recent_changeset_identifier]
      if (!most_recent_revision.nil?)
        child.most_recent_committer = most_recent_revision.user
        child.most_recent_commit_time = most_recent_revision.commit_time
        child.most_recent_commit_desc = most_recent_revision.commit_message
      end
    end
  end
  
end