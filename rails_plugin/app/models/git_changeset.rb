# Copyright (c) 2010 ThoughtWorks Inc. (http://thoughtworks.com)
# Licenced under the Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0.txt)

# describes a git changeset
class GitChangeset

  attr_reader :commit_id
  attr_reader :description
  attr_reader :author
  attr_reader :time

  def initialize(attributes, repository)
    @repository = repository
    attributes.each do |k, v|
      instance_variable_set("@#{k}", v)
    end
  end

  class << self
    def short_identifier(identifier)
      # FIXME: just a hack to get things working.
      identifier[0...12] unless identifier.empty?
    end
  end


  # *returns*: an array of GitChange, one for each path included in the
  # changeset, each containing detail required to render Mingle's Revision 'show'
  # page as well as to populate the source browser cache
  def changes
    changeset_index = 0
    @repository.git_patch_for(self).changes.map do |git_change|
      changeset_index += 1
      GitChange.new(git_change, changeset_index)
    end
  end
end