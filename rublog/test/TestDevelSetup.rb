require 'test/RublogTestCase'

class TestDevelEnvironmentSetup < RublogTestCase
	
  #This may change in the future, but the rublog and eclipse directory can't have spaces
  def test_no_dir_spaces
    assert_equal(nil, File.dirname($0)[' '], "rublog path has spaces")
    assert_equal(nil, File.expand_path(".")[' '], "Workspace path has spaces")
  end
end
