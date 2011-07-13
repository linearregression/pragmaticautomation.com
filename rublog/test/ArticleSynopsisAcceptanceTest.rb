require 'test/RublogTestCase'
require 'test/MockRequest'
require 'test/MockResponse'
require 'test/MockRootDirectory'
require 'Rublog'
require 'View'
require 'Sidebar'
require 'convertors/RDoc'
require 'convertors/Html'

class ArticleSummaryAcceptanceTest < RublogTestCase
	TEMPLATE = 
%{START:entries
%title%-
IFNOT:synopsis
%body%
ENDIF:synopsis
IF:synopsis
%synopsis%
ENDIF:synopsis
END:entries}

  def setup
    @root_dir = MockRootDirectory.new 	  	
    
    @test2_contents = %{  
	  		<title>Test 2</title>
	  		<body>
	  			<summary>second synopsis</summary>
	  			body
	  		</body>}

    @test2_result = %{
	  		<title>Test 2</title>
	  		<body>
	  			<span class="synopsis">second synopsis</span>
	  			body
	  		</body>}

    @root_dir.add("test1.rdoc", "=Test 1\nsummary::first synopsis\n\n1 body")
    @root_dir.add("mydir/test2.html",	@test2_contents)
  end		

  def test_allow_synopsis_is_false
    @root_dir.create_temporarily do |document_dir|
      
      html = load_url('/', document_dir, allow_synopsis = false)
      assert_strip_equal("Test 2-#{@test2_result} Test 1-first synopsis<p>1 body</p>",
                            html, 
			    "should always show body if allow_synopsis == false")
      
    end
  end

  def test_show_synopsis_for_several_files
    @root_dir.add("mydir/test3.rdoc",	"=Test 3\nsummary::third synopsis\n\n3 \nbody")
    
    @root_dir.create_temporarily do |document_dir|
      html = load_url('/', document_dir, allow_synopsis = true)
      assert_strip_equal("Test 3-third synopsis Test 2-second synopsis Test 1-first synopsis", html, "should't show body for base url")
      
      html = load_url('/mydir', document_dir, allow_synopsis = true)
      assert_strip_equal("Test 3-third synopsis Test 2-second synopsis", html, "should't show body for directory url")
      
      html = load_url('/mydir2', document_dir, allow_synopsis = true)
      assert_strip_equal("Not found...-#{NotFoundEntry::HTML_BODY}",
                            html, "nothing's here...")
    end
  end
  
  def test_dont_show_synopsis_for_one_file
    @root_dir.create_temporarily do |document_dir|
      html = load_url('/mydir', document_dir, allow_synopsis = true)
      assert_strip_equal("Test 2-#{@test2_result}", html, "should show body for directory url with one entry")
      
      html = load_url('/mydir/test2.html', document_dir, allow_synopsis = true)
      assert_strip_equal("Test 2-#{@test2_result}", html, "should show body for doc url")
      
      html = load_url('/mydir/test2', document_dir, allow_synopsis = true)
      assert_strip_equal("Test 2-#{@test2_result}", html, "should show body for short doc url")
    end
  end
  
  def test_get_index_rss
    @root_dir.create_temporarily do |document_dir|
      html = load_url('/index.rss', document_dir)
      assert_nonwhitespace_match("<item><title>Test 1</title><link>.*/test1.rdoc</link>" +
                                                                                          "<description>first synopsis.*1 body.*</description></item>",
                                 html, "index.rss is broken")
    end
  end
  
  def test_get_synopsis_rss
    @root_dir.create_temporarily do |document_dir|
      html = load_url('/synopsis.rss', document_dir)
      assert_nonwhitespace_match("<item><title>Test 1</title><link>.*/test1.rdoc</link>" +
                                 "<description>first synopsis...</description></item>",
                                 html)
    end
  end
  
  def load_url(path_info, document_dir, allow_synopsis = false)
    response = MockResponse.new
    request = MockRequest.new('PATH_INFO' => path_info)
    blog = RubLog.new(document_dir, request) {
      set_max_entries_per_page  5
      set_mtime_getter 		proc { |name,stat| Time.now - File.basename(name).hash.abs }
      set_allow_synopsis	allow_synopsis
    }
    
    View.display_with_template(blog, TEMPLATE, response)
    response.to_s
  end
end
