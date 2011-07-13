require "test/RublogTestCase"

MAIN_DIR =  File.join(File.dirname($0), "..")
# perhaps change to a test directory later
BLOG_FILES = File.join(MAIN_DIR, 'doc')

require 'FileEntries'
require 'RubLog'
require 'test/MockRequest'
require 'convertors/RDoc'
require 'convertors/Text'
require 'convertors/Html'
require 'View'

class Tester < RublogTestCase
  attr_reader :entries

  def setup
    @entries = FileEntries.new(BLOG_FILES, nil, nil, Time.at(0), Time.now)
    @fullinst = entries.find_any_entry_named('FullInstallation')
    @rdoc = entries.find_any_entry_named('InputFormats/RdocFormat')
    @blog = RubLog.new(BLOG_FILES, MockRequest.new) 
    @view = HtmlView.new(@blog, CGIResponse.new, @blog.request.style)
    ENV['SCRIPT_NAME'] = 'rub.cgi'
  end

  def test_static_urls
    assert_equal('rub.cgi/FullInstallation.rdoc', @view.url(@fullinst))
    assert_equal('rub.cgi/InputFormats/RdocFormat.rdoc', @view.url(@rdoc))
  end

  def test_dynamic_urls
    @blog.set_use_dynamic_urls true
    assert_equal('rub.cgi/=FullInstallation', @view.url(@fullinst))
    assert_equal('rub.cgi/=RdocFormat', @view.url(@rdoc))		
  end

  def test_dynamic_url_flag
    assert(!@blog.use_dynamic_urls)
    @blog.set_use_dynamic_urls true
    assert(@blog.use_dynamic_urls)
    @blog.use_dynamic_urls = false
    assert(!@blog.use_dynamic_urls)
  end
end
