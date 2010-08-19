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
      @clone_path = File.expand_path(@clone_path) if @clone_path
      @style_dir = style_dir
    end

    def try_to_connect

    end
    
    def pull
      git("fetch -q")
    end

    def ensure_local_clone
      git("clone --bare \"#{@master_path}\" \"#{@clone_path}\"") unless File.file?(@clone_path + '/HEAD')
    end

    def repository_empty?
      Dir["#{@clone_path}/objects/pack/*"].empty?
    end

    def log_for_rev(rev)
      git_log("log #{rev} -1").first
    end

    def log_for_revs(from, to)
      window = from.blank? ? to : "#{from}..#{to}"
      git_log("log #{window}").reverse
    end

    def log_for_path(at_commit_id, *paths)
      cmds = paths.collect do |path|
        "log #{at_commit_id} -1 -- \"#{path}\""
      end
      
      git_log(cmds)
    end

    def git_patch_for(commit_id, git_patch)
      git("log -1 -p #{commit_id} -M") do |stdout|
        
        keep_globbing = true
        stdout.each_line do |line|
          # keep eating away all content until we find the actual diff
          (keep_globbing = false) if line.starts_with?('diff')
          line.chomp!
          git_patch.add_line(line) unless (keep_globbing || line.starts_with?('similarity index '))

        end
      end

      git_patch.done_adding_lines
    end

    def binary?(path, commit_id)

    end

    def cat(path, object_id, io)
      git("cat-file blob #{object_id}") do |stdout|
        
        io << stdout.read
      end
    end

    #FIXME: handle root_path? scenario in ls_tree instead of in dir?
    def dir?(path, commit_id)
      return true if root_path?(path)
      tree = ls_tree(path, commit_id)
      (tree.size == 1) && (tree[path][:type] == :tree)
    end
    

    def ls_tree(path, commit_id, children = false)
      tree = {}
      path += '/' if children && !root_path?(path)
      
      git("ls-tree #{commit_id} \"#{path}\"") do |stdout|
        stdout.each_line do |line|
          mode, type, object_id, path = line.split(/\s+/)
          type = type.to_sym
          tree[path] = {:type => type, :object_id => object_id}
        end
      end
      
      paths = tree.keys
      
      log_for_path(commit_id, *paths).each_with_index do |log_entry, i|
        tree[paths[i]][:last_log_entry] = log_entry
      end

      tree
    end
    
    private
    
    def root_path?(path)
      path == '.' || path.blank?
    end
    
    
    def git(command, &block)
      
      git_prefix = "git --git-dir=\"#{@clone_path}\" --no-pager"
      
      if Array === command
        command = command.collect{ |cmd| "#{git_prefix}  #{cmd}" }.join(" && ")
      else
        command = "#{git_prefix}  #{command}"
      end
    
      execute(command, &block)
    end
    
    def execute(command, &block)
      start = Time.now
      puts "Executing command:\n#{command}" if GitClient.logging_enabled

      error = nil
      
      Open3.popen3(command) do |stdin, stdout, stderr|
        stdin.close
        yield(stdout) if block_given?
        error = stderr.readlines
      end
      
      if GitClient.logging_enabled
        time_in_ms = ((Time.now - start)*1000).to_i
        puts "execute using #{time_in_ms}ms"
      end
      
      raise StandardError.new("Could not execute \"#{command}\". The error was:\n#{error}" ) unless error.empty?
    end
    
    
    def git_log(command)
      
      raise "Repository is empty!" if repository_empty?
      
      result = []

      git(command) do |stdout|
        log_entry = {}
        stdout.each_line do |line|
          line.chomp!
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
            log_entry[:description] << line.strip
          end
        end
        
      end


      result
    end
  end
# 
# else
#   raise 'you need to implement git for the jruby platform'
# end
