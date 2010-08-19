# Copyright (c) 2010 ThoughtWorks Inc. (http://thoughtworks.com)
# Licenced under the Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0.txt)

require 'uri'
class GitConfiguration < ActiveRecord::Base

  include RepositoryModelHelper
  include PasswordEncryption

  strip_on_write

  belongs_to :project
  validates_presence_of :repository_path
  after_create :remove_cache_dirs
  after_destroy :remove_cache_dirs

  def self.display_name
    "Git"
  end

  def vocabulary
    {
      'revision' => 'changeset',
      'committed' => 'author',
      'repository' => 'repository',
      'head' => 'master',
      'short_identifier_length' => 12
    }
  end

  def view_partials
    {:node_table_header => 'git_source/node_table_header',
     :node_table_row => 'git_source/node_table_row' }
  end

  def source_browsing_ready?
    initialized?
  end

  def validate
    super
    
    begin
      uri = URI.parse(repository_path)
    rescue
      errors.add_to_base(%{
        The repository path appears to be of invalid URI format.
        Please check your repository path.
      })
    end

    if uri && !uri.password.blank?
      errors.add_to_base(%{
        Do not store repository password as part of the URL.
        Please use the supplied form field.
      })
    end
  end
  
  def repository
    clone_path = File.expand_path(File.join(MINGLE_DATA_DIR, "git", project.identifier))
    puts "clone_path: #{clone_path}"
    
    mingle_rev_repos = GitMingleRevisionRepository.new(project)
    
    scm_client = GitClient.new(repository_path_with_userinfo, clone_path)
    
    source_browser = GitSourceBrowser.new(scm_client)
    
    repository = GitRepository.new(scm_client, source_browser)
    GitRepositoryClone.new(repository)
  end
  
  def repository_location_changed?(configuration_attributes)
    self.repository_path != configuration_attributes[:repository_path]
  end
  
  def clone_repository_options
    {:repository_path => self.repository_path, :username => self.username, :password => self.password}
  end

  def repository_path_with_userinfo
    uri = URI.parse(repository_path)
    return repository_path if uri.scheme.blank?

    if !username.blank? && !password.blank?
      "#{uri.scheme}://#{username}:#{password}@#{host_port_path_from(uri)}"
    elsif !username.blank?
      "#{uri.scheme}://#{username}@#{host_port_path_from(uri)}"
    elsif !uri.user.blank? && password.blank?
      "#{uri.scheme}://#{uri.user}@#{host_port_path_from(uri)}"
    elsif !uri.user.blank? && !password.blank?
      "#{uri.scheme}://#{uri.user}:#{password}@#{host_port_path_from(uri)}"
    else
      repository_path
    end
  end
  
  def host_port_path_from(uri)
    result = "#{uri.host}"
    result << ":#{uri.port}" unless uri.port.blank?
    result << "#{uri.path}"
    result
  end

  private
  
  def remove_cache_dirs
    FileUtils.rm_rf(File.expand_path(File.join(MINGLE_DATA_DIR, 'git', id.to_s)))
  end
  
end

