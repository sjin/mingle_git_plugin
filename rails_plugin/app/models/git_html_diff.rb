# Copyright 2010 ThoughtWorks, Inc. Licensed under the Apache License, Version 2.0.

require 'erb'

# GitHtmlDiff produces an HTML snippet containing the diff for a single file change
class GitHtmlDiff
  
  # construct HgHtmlDiff from an HgGitChange
  def initialize(git_change, changeset_index)
    @git_change = git_change
    @changeset_index = changeset_index
  end
  
  # *returns*: an HTML snippet containing the diff for a single file change
  def content
    escaped_lines = @git_change.lines.map{|l| ERB::Util.h(l)}
    line_index = 0
    color_lines = escaped_lines.map do |line|
      line_index += 1
      anchor_id = "#{@changeset_index}.#{line_index}"
      "<a style=\"color: gray; text-decoration: none;\" href=\"##{anchor_id}\" id=\"#{anchor_id}\">#{padded_line_number(@changeset_index, line_index)}</a> <span style=\"color:#{line_color(line)};\">#{line}</span><br/>"
    end
    if @git_change.truncated?
      color_lines << " "*10 + "<span style=\"color: gray; text-decoration: none;\">...</span><br/>"
      color_lines << " "*10 + "<span style=\"color: gray; text-decoration: none;\">diff truncated</span><br/>"
    end
    "<div style=\"font-family: Courier, monospace;\"><pre>#{color_lines}</pre></div>"
  end
    
  #:nodoc:
  def padded_line_number(changeset_index, line_index)
    line_number = "#{changeset_index}.#{line_index}"
    while (line_number.length < 10)
      line_number = " #{line_number}"
    end
    line_number
  end

  #:nodoc:
  def line_color(line)
    if line =~ /^\+/
      "#008800"
    elsif line =~ /^\-/
      "#CC0000"
    elsif line =~ /^\@/
      "#990099"
    else
      "#000000"
    end
  end
  
end