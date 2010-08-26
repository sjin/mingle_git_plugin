# Copyright (c) 2010 ThoughtWorks Inc. (http://thoughtworks.com)
# Licenced under the Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0.txt)

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper'))

require 'ostruct'

class GitSourceBrowserTest < Test::Unit::TestCase

  def setup_repos(bundle)
    @repos, @source_browser = TestRepositoryFactory.create_repository_with_source_browser(bundle)
  end
  
  def test_node_returns_file_node_for_file_path
    setup_repos('one_changeset')
    
    assert !@source_browser.node('README', "19df35cdb7d0219cb2b1adfe791d7b27bf14fda8").dir?
  end
  
  def test_node_returns_dir_node_for_dir_path
    setup_repos('one_changeset_with_subdirs')
    node = @source_browser.node('src', "58eec0e41c32000f90dfa7c8f18d0391b4165013")
    assert node.dir?
  end
  
  def test_node_returns_dir_node_for_root
    setup_repos('one_changeset')
    
    assert @source_browser.node('.', "19df35cdb7d0219cb2b1adfe791d7b27bf14fda8").dir?
  end
  
  def test_can_get_children_of_root_node
    setup_repos('one_changeset_with_many_files')
    children = @source_browser.node('.', "266e42ded6dcbaeac3dff370effe2ab0c33a9c09").children
    assert_equal ['README', 'src', 'tests'].sort, children.map(&:path).sort
  end
  
  def test_can_get_children_of_root_node_when_root_contains_dot_files
    setup_repos('dot_files')
        
    children = @source_browser.node('.', "2a6477b7d82501197c9c1b558675e3411e42d877").children
    assert_equal ['.bar', '.foo', 'foobar'].sort, children.map(&:path).sort
  end
    
  def test_can_get_children_of_non_root_node
    setup_repos('one_changeset_with_many_files')
    # FIXME: figure out the trailing slash issue. git ls-tree needs a trailing slash on dirnames
    children = @source_browser.node('src', "266e42ded6dcbaeac3dff370effe2ab0c33a9c09").children
    assert_equal ['src/foo', 'src/foo.rb'].sort, children.map(&:path).sort
  end
  
  def test_can_get_children_of_non_root_node_when_node_contains_dot_files
    setup_repos('dot_files')
    
    children = @source_browser.node('foobar', "2a6477b7d82501197c9c1b558675e3411e42d877").children
    assert_equal ['foobar/.stuff', 'foobar/non_dot.txt'].sort, children.map(&:path).sort
  end
  
  def test_can_get_children_of_non_root_node_when_node_is_a_dot_file
    setup_repos('dot_files')
    
    children = @source_browser.node('.bar', "2a6477b7d82501197c9c1b558675e3411e42d877").children
    assert_equal ['.bar/.stuff.txt', '.bar/stuff.txt'].sort, children.map(&:path).sort
  end
  
  def test_children_are_correct_node_types
    setup_repos('one_changeset_with_many_files')
    children = @source_browser.node('src', "266e42ded6dcbaeac3dff370effe2ab0c33a9c09").children
    assert children.find{|c| c.name == 'foo'}.dir?
    assert !children.find{|c| c.name == 'foo.rb'}.dir?
  end
  
  def test_most_recent_commit_information_is_included_in_child_nodes
    setup_repos('hello')

    dir = @source_browser.node('.', "8cf18930f5c6f457cec89011dfe45d8aff07d870")
    @source_browser.instance_variable_get("@git_client").pull
    children = dir.children
    children.map(&:load_last_log_entry)
    hello_c_file = children.find{|c| c.path == 'hello.c'}
    assert_equal "Bryan O'Sullivan <bos@serpentine.com>", hello_c_file.most_recent_committer
    assert_equal "Introduce a typo into hello.c.", hello_c_file.most_recent_commit_desc
    assert_equal Time.parse('Sat Aug 16 22:05:04 -0700 2008'), hello_c_file.most_recent_commit_time
    
    makefile = children.find{|c| c.path == 'Makefile'}
    assert_equal "Bryan O'Sullivan <bos@serpentine.com>", makefile.most_recent_committer
    assert_equal "Get make to generate the final binary from a .o file.", makefile.most_recent_commit_desc
    assert_equal Time.parse('Sat Aug 16 22:08:02 -0700 2008'), makefile.most_recent_commit_time
    
  end
  
  def test_can_get_file_contents_from_fixed_node
    setup_repos('hello')
    node = @source_browser.node("hello.c", "2cf7a6a5e25f022ac4b18ce7165661cdc8177013")
    io = StringIO.new
    node.file_contents(io)

    expected_file_contents = %q{/*
 * hello.c
 *
 * Placed in the public domain by Bryan O'Sullivan
 *
 * This program is not covered by patents in the United States or other
 * countries.
 */

#include <stdio.h>

int main(int argc, char **argv)
{
	printf("hello, world!\n");
	return 0;
}
}

    assert_equal(expected_file_contents, io.string)
  end

  def assert_equal_hash(expected, actual)
    assert_equal(expected.keys.sort, actual.key_set.sort)
    expected.keys.each do |k|
      unless expected[k] == actual[k]
        fail("Value of #{k} expected to be #{expected[k]} but was #{actual[k]}")
      end
    end
  end  
  
  def test_should_detect_binary_files
    setup_repos('renames')
    assert @source_browser.node('WorstestEver.png', 'master').binary?
    assert !@source_browser.node('some_stuff.txt', 'master').binary?
  end
  
  def test_last_log_entry_should_be_populated_to_cache_on_first_load
    
  end
end