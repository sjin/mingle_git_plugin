# Copyright (c) 2010 ThoughtWorks Inc. (http://thoughtworks.com)
# Licenced under the Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0.txt)

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper'))

class GitClientMimeTypesTest < Test::Unit::TestCase

  def test_mime_type_for_file_with_single_ext
    assert_equal 'text/x-java-source', GitClientMimeTypes.lookup_for_file('src/foo.java')
    assert_equal 'text/x-java-source', GitClientMimeTypes.lookup_for_file('src/foo.JAVA')
    assert_equal 'text/plain', GitClientMimeTypes.lookup_for_file('src/foo.rb')
    assert_equal 'application/x-jar', GitClientMimeTypes.lookup_for_file('src/foo.jar')
    assert_equal 'application/xml', GitClientMimeTypes.lookup_for_file('src/build.xml')
    assert_equal 'text/html', GitClientMimeTypes.lookup_for_file('src/index.html')
    assert_equal 'text/css', GitClientMimeTypes.lookup_for_file('src/style.css')
    assert_equal 'text/javascript', GitClientMimeTypes.lookup_for_file('src/jquery.js')
  end
  
  def test_mime_type_for_file_multi_ext
    assert_equal "application/x-tar", GitClientMimeTypes.lookup_for_file("a.tar.gz")
    assert_equal "application/x-bzip2", GitClientMimeTypes.lookup_for_file("a.tar.bz2")
    assert_equal "application/x-tar", GitClientMimeTypes.lookup_for_file("a.tar.foo")
  end
  
  def test_mime_type_for_file_without_ext_is_text_plain
    assert_equal "text/plain", GitClientMimeTypes.lookup_for_file("foo")
    assert_equal 'text/plain', GitClientMimeTypes.lookup_for_file('src/README')
    assert_equal 'text/plain', GitClientMimeTypes.lookup_for_file('src/INSTALL')
    assert_equal 'text/plain', GitClientMimeTypes.lookup_for_file('src/Copyright')
    assert_equal 'text/plain', GitClientMimeTypes.lookup_for_file('src/Rakefile')
    assert_equal 'text/plain', GitClientMimeTypes.lookup_for_file('src/ChangeLog')
    assert_equal 'text/plain', GitClientMimeTypes.lookup_for_file('src/CHANGELOG')
  end
  
  def test_mime_type_for_file_ext_unknow_is_text_plain
    assert_equal 'text/plain', GitClientMimeTypes.lookup_for_file('src/foo.foobar')
  end
 
end