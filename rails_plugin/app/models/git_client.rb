require 'time'
unless RUBY_PLATFORM =~ /java/
  require 'open3'
  # this is used only in tests
  class GitClient
    
    def initialize(master_path, clone_path, style_dir)
      @master_path = master_path
      @clone_path = clone_path
      @style_dir = style_dir
    end
  
    def repository_empty?
      command = "cd #{@clone_path} && /opt/local/bin/git log -1"
      result = ""
      Open3.popen3(command) do |stdin, stdout, stderr|
        begin
          result = stdout.readline
        rescue Exception => e
          # do nothing, maybe git barfed
        end
      end
      return !result.starts_with?('commit') 
    end
    
    def log_for_rev(rev)
      log_for_revs(rev, rev).first
    end
        
    def log_for_revs(from, to)
      raise "Repository is empty!" if repository_empty?
      
      command = "cd #{@clone_path} && /opt/local/bin/git log #{from} #{to}"
      result = []

      error = ''
      Open3.popen3(command) do |stdin, stdout, stderr|
        log_entry = {}
        error = stderr.readlines
        stdout.each_line do |line|
          line.strip!
          if line.starts_with?('commit')
            log_entry = {}
            log_entry[:commit_id] = line.sub(/commit /, '')
            log_entry[:description] = ''
            result << log_entry
          elsif line.starts_with?('Author:')
            log_entry[:author] = line.sub(/Author: /, '')
          elsif line.starts_with?('Date:')
            log_entry[:time] = Time.parse(line.sub(/Date:   /, ''))
          else
           log_entry[:description] << line
          end
        end
      end

      raise StandardError.new("Could not execute '#{command}'. The error was:\n#{error}" ) unless error.empty?
      
      result
    end
  
  end
  
else
  raise 'you need to implement git for the jruby platform'
end
