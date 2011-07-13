require "test/MockRootDirectory"
require 'test/RublogTestCase'
require "FileEntries"
require "BaseConvertor"
require "Convertors/Html"

class TestFileEntries < RublogTestCase
  def test_no_dir
    entries = FileEntries.new("nodirectory", nil, nil, Time.at(0), Time.now);
    assert_equal(0, entries.entries.length)
  end	  	
  
  def test_converts_htm
    files = MockRootDirectory.new('somewhereelse')
    files.add("a.html")
    files.add("b.htm")
    files.create_temporarily do |dir|
      entries = FileEntries.new(dir, nil, nil, Time.at(0), Time.now + 1000);
      assert_equal(2, entries.entries.length)
    end
  end
end

