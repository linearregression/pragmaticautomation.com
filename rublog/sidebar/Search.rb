require "Sidebar"
require "search/Searcher"

# Handle a 'Search' sidebar. We keep the search string in the
# CGI variable 'terms'. If set, we perform a search
# and display the result. Otherwise we simply display the empty form.
#
#  require 'sidebar/Search'
#  SearchSidebar.new(blog)
#

class SearchSidebar < Sidebar

  HANDLES = "searching"

  SEARCH_BOX = %{
IF:warnings
<ul class="sidebarwarning">
START:warnings
<li>%warning%</li>
END:warnings
</ul>
ENDIF:warnings
IFNOT:warnings
<div class="sidebartext">(word|+word|-word)...</div>
ENDIF:warnings
<form method="post" action="">
<div>
<input name="terms" value="%terms%" />
IF:label
<input type="submit" value="%label%" />
ENDIF:label
<input type="hidden" name="handler" value="#{HANDLES}" />
</div>
</form>
}

  def initialize(cache_file, label = " SEARCH ")
    super()
    @cache_file = cache_file
    @label = label
  end


  def title
    "Search"
  end

  def generate(blog)
    values = { 
      'terms' => blog.get_parameter('terms'),
      'label' => @label
    }

    unless blog.warnings.empty?
      values['warnings'] = blog.warnings.map do |w|
	{ 'warning' => w }
      end
    end

    @body = ""
    template = Template.new(SEARCH_BOX)
    template.write_html_on(@body, values)
  end

  # Come here to handle searching. Return 'true' if we did,
  # false if not
  def handle(blog, request)
    terms = request.get_parameter('terms')
    return false if !terms || terms.empty?

    # Otherwise search for matching documents

    s = Searcher.load(blog, @cache_file)
    sr = s.find_words(terms.split)

    if sr.contains_matches
      blog.process_search_results(sr.results)
    else
      blog.set_warnings(sr.warnings)
      return false
    end
  end

end
