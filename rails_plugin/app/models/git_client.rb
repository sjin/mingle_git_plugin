# Copyright (c) 2010 ThoughtWorks Inc. (http://thoughtworks.com)
# Licenced under the Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0.txt)

require 'time'
require 'fileutils'
# unless RUBY_PLATFORM =~ /java/
  require 'open3'
  # this is used only in tests
  class GitClient

    cattr_accessor :logging_enabled

    def initialize(master_path, clone_path, style_dir)
      @master_path = master_path
      @clone_path = clone_path
      if master_path && master_path =~ /\//
        @clone_path += '/' + master_path.split('/').last.gsub(/.git$/,'') + '.git'
      end
      @style_dir = style_dir
    end

    def try_to_connect

    end
    
    def pull
      command = "cd #{@clone_path} && /opt/local/bin/git --no-pager fetch -q"
      
      error = ''
      execute(command) do |stdin, stdout, stderr|
        stdin.close
        error = stderr.readlines
      end
      
      raise StandardError.new("Could not execute '#{command}'. The error was:\n#{error}" ) unless error.empty?
    end

    def ensure_local_clone
      base_dir = File.dirname(@clone_path)
      FileUtils.mkdir_p(base_dir)
      head_file = @clone_path + '/HEAD'
      unless File.file?(head_file)
        command = "cd #{base_dir} && /opt/local/bin/git --no-pager clone --bare #{@master_path}"
        error = ''
        execute(command) do |stdin, stdout, stderr|
          stdin.close
          error = stderr.readlines
        end

        raise StandardError.new("Could not execute '#{command}'. The error was:\n#{error}" ) unless error.empty?

      end
    end

    def repository_empty?
      command = "cd #{@clone_path} && /opt/local/bin/git --no-pager log -1"
      result = ""
      execute(command) do |stdin, stdout, stderr|
        stdin.close
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

      command = "cd #{@clone_path} && /opt/local/bin/git --no-pager log #{from} #{to}"
      result = []

      error = ''
      execute(command) do |stdin, stdout, stderr|
        stdin.close
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

    def git_patch_for(commit_id, git_patch)
      command = "cd #{@clone_path} && /opt/local/bin/git --no-pager log -1 -p #{commit_id} -M"

      error = ''
      execute(command) do |stdin, stdout, stderr|
        stdin.close
        keep_globbing = true
        stdout.each_line do |line|
          # keep eating away all content until we find the actual diff
          (keep_globbing = false) if line.starts_with?('diff')

          git_patch.add_line(line) unless (keep_globbing || line.starts_with?('similarity index '))

        end
      end

      raise StandardError.new("Could not execute '#{command}'. The error was:\n#{error}" ) unless error.empty?

      git_patch.done_adding_lines
    end

    def binary?(path, commit_id)

    end

    # return a hash containing the file path and the
    def ls_tree(path, commit_id)
      tree = {}

      command = "cd #{@clone_path} && /opt/local/bin/git --no-pager ls-tree #{commit_id} #{path}"
      
      execute(command) do |stdin, stdout, stderr|
        stdin.close
        stdout.each_line do |line|
          mode, type, object_id, path = line.split(/\s+/)
          type = type.to_sym
          path += '/' if type == :tree
          
          tree[path] = {:type => type, :object_id => object_id}
        end
      end
      
      if dir?(tree)
        tree = {}
        
        command = "cd #{@clone_path} && /opt/local/bin/git --no-pager ls-tree #{commit_id} #{path}"

        execute(command) do |stdin, stdout, stderr|
          stdin.close
          stdout.each_line do |line|
            mode, type, object_id, path = line.split(/\s+/)
            type = type.to_sym
            path += '/' if type == :tree

            tree[path] = {:type => type, :object_id => object_id}
          end
        end
      end
      tree
    end

    def cat(path, object_id, io)
      command = "cd #{@clone_path} && /opt/local/bin/git --no-pager cat-file blob #{object_id}"

      execute(command) do |stdin, stdout, stderr|
        stdin.close
        io << stdout.read
      end
    end

    private
    
    private 
    def dir?(tree)
      tree.size == 1 && tree.values.first[:type] == :tree
    end
    
    def execute(command, &block)
      puts "Executing command:\n#{command}\n Called from #{caller}" if GitClient.logging_enabled
      Open3.popen3(command, &block)
    end
  end
# 
# else
#   raise 'you need to implement git for the jruby platform'
# end
