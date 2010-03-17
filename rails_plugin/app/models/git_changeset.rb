# describes a git changeset
class GitChangeset

  attr_reader :commit_id
  attr_reader :description
  attr_reader :author
  attr_reader :time
  
  def initialize(attributes, repository)
    @repository = repository
    puts attributes[:time]
    attributes.each do |k, v|
      instance_variable_set("@#{k}", v)
    end
  end
  
  
end