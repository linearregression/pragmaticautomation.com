require 'test/unit'

class RublogTestCase < Test::Unit::TestCase

  def test_so_rublog_doesnt_fail_because_it_doesnt_have_tests
  end
  
  def assert_strip_equal(expected, actual, message=nil) 
    begin
      assert_equal(strip_spaces(expected),
                   strip_spaces(actual),
                   message)
    rescue
      puts caller[0]
      raise
    end
  end
  
  def assert_nonwhitespace_match(expected, actual, message=nil)
    begin
      assert_match(Regexp.new(strip_spaces(expected)),
                   strip_spaces(actual),
                   message)
    rescue
      puts caller[0]
      raise
    end
  end
  
  private

  def strip_spaces(string)
    string.gsub(/[ \n\t]/, '')
  end
end
