COMPATIBLE_MINGLE_VERSIONS = ['3_0', 'unstable_3_0', 'unsupported-developer-build']

if COMPATIBLE_MINGLE_VERSIONS.include?(MINGLE_VERSION)

  begin
    require File.expand_path(File.join(File.dirname(__FILE__), 'app/models/git_configuration'))
    MinglePlugins::Source.register(GitConfiguration)
  rescue Exception => e
    ActiveRecord::Base.logger.error "Unable to register GitConfiguration. Root cause: #{e}"
  end
  
else
  ActiveRecord::Base.logger.warn %{
    The plugin mingle_git_plugin is not compatible with Mingle version #{MINGLE_VERSION}. 
    This plugin only works with Mingle version(s): #{COMPATIBLE_MINGLE_VERSIONS.join(', ')}.
    The plugin mingle_git_plugin will not be available.
  }
end

