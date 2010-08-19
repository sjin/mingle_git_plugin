# Copyright (c) 2010 ThoughtWorks Inc. (http://thoughtworks.com)
# Licenced under the Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0.txt)

# describes a git changeset
class GitChangeset

  attr_reader :commit_id
  attr_reader :description
  attr_reader :author
  attr_reader :time
  attr_accessor :number
  
  class << self
    def short_identifier(identifier)
      identifier[0...12]
    end
  end

  def initialize(attributes, repository)
    @repository = repository
    attributes.each do |k, v|
      instance_variable_set("@#{k}", v)
    end
  end
  
  def changes
    return @__changes if @__changes
    changeset_index = 0
    @__changes = @repository.git_patch_for(self).changes.map do |git_change|
      changeset_index += 1
      GitChange.new(git_change, changeset_index)
    end
    
    @__changes
  end
  
  alias :changed_paths :changes
  alias :identifier :commit_id
  alias :message :description
  alias :version_control_user :author
end