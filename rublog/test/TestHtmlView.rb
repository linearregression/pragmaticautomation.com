require 'BaseConvertor'
require 'test/RublogTestCase'
require 'test/MockRequest'
require 'test/MockResponse'
require 'test/Sham'
require 'View'
require 'Sidebar'

class TestHtmlView < RublogTestCase
	SIMPLE_BODY_OR_SYNOPSIS_TEMPLATE =
%{START:entries
IFNOT:synopsis
%body%
ENDIF:synopsis
IF:synopsis
%synopsis%
ENDIF:synopsis
END:entries}

  def setup
    @rublog = MockRublog.new
  end
  
  def test_smoke 
    HtmlView.new(nil, nil, nil)
  end
	
  def test_render 
    @rublog.add_file(:file_name => "file1.txt",
                     :title     =>"mytitle", 
                     :body      => "mybody")
    @rublog.all_entries.entries[0].title = "mytitle"
    
    template = 
%{START:entries
%title%|%url%|%-body%
END:entries}

    assert_equal("mytitle|/file1.txt|mybody\n\n", render(template))
  end
	
  def test_render_synopsis_with_more_than_one_file 
    @rublog.add_file(:file_name => "file1.txt", 
                     :synopsis  => "first synopsis", 
                     :body      => "first synopsis body")
    @rublog.add_file(:file_name => "file2.txt",
                     :synopsis  => "second synopsis", 
                     :body      => "second synopsis body")
    @rublog.defineShamMethod(:allow_synopsis) { true }

    assert_strip_equal("first synopsis second synopsis", 
                       render(SIMPLE_BODY_OR_SYNOPSIS_TEMPLATE))
  end
	
  def test_dont_render_just_synopsis_with_one_file 
    @rublog.add_file(:file_name => "file1.txt",
                     :synopsis => "first synopsis",
                     :body => "first synopsis body")
    @rublog.defineShamMethod(:allow_synopsis) { true }
    
    assert_strip_equal("first synopsis body", 
                       render(SIMPLE_BODY_OR_SYNOPSIS_TEMPLATE))
  end
	
  def test_rss_links
    assert_strip_equal("http://localhost:80/cgi-bin/rublog/index.rss",
                       render("%fulltext_rss_url%"))
    assert_strip_equal("http://localhost:80/cgi-bin/rublog/synopsis.rss",
                       render("%synopsis_rss_url%"))
  end
  
  def render(template_text)
    response = MockResponse.new
    view = HtmlView.new(@rublog, response, template_text)
    view.render
    response.to_s
  end
		
  class MockFileEntry < FileEntry
    attr_accessor :title
    attr_accessor :synopsis
    attr_accessor :body
    
    def initialize(keyword_args)
      keyword_args.default = ''
      super(keyword_args[:file_name], Time.now(), nil, nil, 1, true)
      @title = keyword_args[:title]
      @synopsis = keyword_args[:synopsis]
      @body = keyword_args[:body]
    end
    
    def convert
      HTMLEntry.new(@title, @body, @synopsis)
    end
    
    def base_name
      file_name
    end
  end
  
  class MockRublog < Sham
    def initialize
      super
      @entries = FileEntries.new("nosuchdirectory", 
                                 nil,
                                 nil,
                                 Time.at(0),
                                 Time.now + 1000);
    end
    
    def request
      MockRequest.new
    end
    
    def all_entries
      @entries
    end
    
    def displayed_entries
      @entries
    end
    
    def page_size
      10
    end
    
    def page_is_past_requested_date
      true
    end
    
    def start_index	
      0
    end
    
    def add_file(file_properties)
      entry = MockFileEntry.new(file_properties)
      entry.all_entries = @entries
      @entries.entries << entry
    end
  end	
end
