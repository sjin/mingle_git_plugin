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
      identifier[0...12]
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