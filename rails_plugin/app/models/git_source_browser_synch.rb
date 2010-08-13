# Copyright (c) 2010 ThoughtWorks Inc. (http://thoughtworks.com)
# Licenced under the Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0.txt)

# GitSourceBrowserSynch is GitRepository decorator that 
# keeps the source browser in synch with the repository
class GitSourceBrowserSynch
  
  def initialize(repository, source_browser)
    @repository = repository
    @source_browser = source_browser
  end
  
  def method_missing(method, *args)
    result = @repository.send(method, *args)
    synch(args[0], result) if (method.to_sym == :next_revisions) 
    result
  end
  
  def synch(skip_up_to, most_recently_cached_changesets)
    return if skip_up_to.nil? && most_recently_cached_changesets.empty?
           
    # check that previously cached changesets are still OK
    last_rev_number = if most_recently_cached_changesets.last
      most_recently_cached_changesets.last.number
    else
      skip_up_to.number
    end
    0.upto(last_rev_number) do |rev_number|
      unless @source_browser.cached?(rev_number)
         @source_browser.ensure_file_cache_synched_for(rev_number) 
      end       
    end
    
    # check that any old caches are cleaned up as the cache uses a lot of disk space
    @source_browser.clean_up_obsolete_cache_files
    
  end
  
end

