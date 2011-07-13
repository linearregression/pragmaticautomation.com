require 'test/RublogTestCase'

class TestRequest < RublogTestCase
  def test_default_settings
    request = MockRequest.new
    assert_equal("http://localhost:80/cgi-bin/rublog/",
                 request.url_of_script)
    assert_equal("http://localhost:80/cgi-bin/rublog//intellij/KnownIssues.txt",
                 request.my_url)
    assert_equal("intellij/KnownIssues.txt",
                 request.path)
  end
  
  def test_override
    request = MockRequest.new("PATH_INFO" => "this is path info")
    assert_equal("http://localhost:80/cgi-bin/rublog/this is path info",
                 request.my_url)
    assert_equal("this is path info",
                 request.path)
  end
  
  def test_rss
    request = MockRequest.new("PATH_INFO" => "/this is path info")
    assert(!request.is_fulltext_rss)
    assert(!request.is_synopsis_rss)
    assert_equal("this is path info", request.path)
    
    request = MockRequest.new("PATH_INFO" => "/index.rss")
    assert(request.is_fulltext_rss)
    assert(!request.is_synopsis_rss)
    assert_equal("", request.path)
    
    request = MockRequest.new("PATH_INFO" => "/synopsis.rss")
    assert(!request.is_fulltext_rss)
    assert(request.is_synopsis_rss)
    assert_equal("", request.path)
  end
end
