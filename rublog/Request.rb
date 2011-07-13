# Represent the incoming request, mapping it to an internal
# class. This insulates the rest of the code from knowing whether
# parameters are passed as part of the path or as parameters in the URL

require 'parsedate'

class Request

  # The path to the file to load
  attr_accessor :path

  # Is this a request for a (synoptic) RSS feed or for a normal HTML display
  attr_accessor :is_fulltext_rss
  attr_accessor :is_synopsis_rss

  # the timestamp of the minimum article to display
  attr_accessor :min_time

  # and the timestamp of the maximum
  attr_accessor :max_time

  # how many entries to display on a page
  attr_accessor :entries_per_page

  # Where to start from in the list
  attr_accessor :start_from

  # Or which specific article to display (by name)
  attr_accessor :show_article_with_name

  # Overriding style to display the output pages in. Nil means
  # use the default
  attr_accessor :style


  # Some protocols allow you to request a page only if it has been modified
  # after a given datetime (for example http's if-modified-since header).
  # Return this datetime. The default, implemented here, simply
  # returns true

  def wants_page_dated(page_dtm)
    true
  end

  # Come here to dispatch to the correct handler. If a 'handle' CGI
  # variable is set, and if we recognize it, then dispatch to
  # that handler, otherwise just use the default RubLog handler

  def handle(rublog)
    handler_name = get_parameter('handler')

    handler = Sidebar.find_handler(handler_name)

    handled = false
    if handler
      handled = handler.handle(rublog, self)
    end

    rublog.process_default_display unless handled
  end

  def date_range_to_s
    if @min_time.to_i.zero?
      "asof=#{@max_time.strftime("%Y/%m/%d")}"
    else
      "for_date=#@date_spec"
    end
  end

end


# Handles all requests from web applications.  
# Subclasses should provide:
# @parameters: Hash-like object which responds to #[] and #hash_key?
# @environment: Hash-like object which responds to #[]
class WebRequest < Request
  def initialize
    super
    determine_request_path
    determine_style
    determine_date_range
    determine_entries_per_page
    determine_start_from
    determine_specific_name
  end

  # Check to see if the document is modified after the request's
  # if-modified-since header

  def wants_page_dated(page_dtm)
    ims = @environment['HTTP_IF_MODIFIED_SINCE']
    if ims
      begin
	ims_time = Time.gm(*ParseDate.parsedate(ims)[0,6])
	return ims_time < page_dtm
      rescue
	$stderr.puts $!
	;
      end
    end
    return true
  end

  def get_parameter(name)
    @parameters[name]
  end

  # Return the URL or our server
  def url_of_server
    res = "http://"
    if @environment['HTTP_HOST']
      res << @environment['HTTP_HOST']
    else 
      res << @environment['SERVER_NAME'] << ":" << @environment['SERVER_PORT']
    end
    res
  end

  # and the URL of this script
  def url_of_script
    url_of_server + @environment['SCRIPT_NAME'] 
  end

  # and the URL of this request
  def my_url
    res = url_of_script
    res << @environment['PATH_INFO'] if @environment['PATH_INFO']
    query = @environment['QUERY_STRING']
    if query && !query.empty?
      res << "?" << @environment['QUERY_STRING']
    end
    res
  end

  # Convert a file path into a URL
  def make_url(path)
    url_of_server + path
  end

 
  # Are we an request for some form of rss?
  def is_rss
    @is_fulltext_rss || @is_synopsis_rss
  end

  #######
  private
  #######

  # Work out the request path, and make it local to out datadir. Ignore it
  # if it contains any '..' sequences

  def determine_request_path
    request_path = ""
    path = @environment['PATH_INFO']
    if path && path !~ /\.\./
      path = path.dup
      path.slice!(0) if path[0] == ?/
      request_path = path unless path.empty?
    end

    @is_fulltext_rss = request_path.sub!(/index.rss$/, '') || @parameters.has_key?('rss')
    @is_synopsis_rss = request_path.sub!(/synopsis.rss$/, '') || @parameters.has_key?('synopsisrss')

    @path = request_path
  end

  # Look for a style to use. Again we encode it in the URL to enable caching
  # We look for /style/<name>
  def determine_style
    @style = $1 if @path.sub!(%r{/?style/(\w+)}, '')
  end

  # What's the date range of articles to display? If we have an
  # 'asof=' parameter, then that determines the maximum time to
  # display, and the minimum is epoch. If we have
  # a 'for_date' parameter, or if the path ends in
  # an apparent date, we set the min and max to encompass that
  # data. For example, for_date=2000 sets the min to Jan 1, 2000, and
  # the max to Jan 1, 2001, while for_DATE=2002/3/4 displays just the
  # entries for that particular day

  def determine_date_range
    @min_time = Time.at(0)
    @max_time = Time.now
    begin
      if @parameters.has_key?('asof')
	@date_spec = @parameters['asof']
	y,m,d = @date_spec.split("/")
	@max_time = Time.local(y, m, d, 11, 59, 59)
      else
	@date_spec = nil

	if @parameters.has_key?('for_date')
	  @date_spec = @parameters['for_date']
	elsif @path.sub!(%r{\b(\d\d\d\d(/\d\d?(/\d\d?)?)?)$}, '') ||
	  @date_spec = $1
	end

	if @date_spec
	  y,m,d = @date_spec.split("/").map {|n| Integer(n.sub(/^0/, ''))}
	  @min_time = Time.local(y,m,d)
	  if d
	    @max_time = @min_time + 24*60*60
	  elsif m
	    m += 1
	    if m > 12
	      m = 1; y += 1
	    end
	    @max_time = Time.local(y,m)
	  else
	    @max_time = Time.local(y+1)
	  end
	end
      end
    rescue ArgumentError
      ;
    end
    @max_time -= 1  # So we don't accidentally enter the next day
  end
    
  # How many entries to show on a page: either the value of the
  # CGI parameter +count+ or the value of the configuration
  # parameter +max_entries_per_page+.
  
  def determine_entries_per_page
    if @parameters.has_key?('count')
      val = @parameters['count']
      (@entries_per_page = Integer(val))  rescue ArgumentError
    end
  end

  # If the path contains "+<path>...", or if the parmeters contain
  # start=<path>, then we set that as the name of the first
  # article to display
  def determine_start_from
    if @parameters.has_key?('start_from')
      @start_from = @parameters['start_from']
    elsif @path.sub!(/\+(.*)/, '')
      @start_from = $1
    end
  end

  # Martin Fowler wants the ability to access an article by its name (which
  # is quite nice, as it philosophically helps with the blog/wiki
  # convergence). We support either the parameter 'name=xxx', or the
  # url syntax =xxx. The latter is preferred (because we can then cache)
  def determine_specific_name
    if @parameters.has_key?('name')
      @show_article_with_name = @parameters['name']
    elsif @path.sub!(/=([^\/]+)/, '')
      @show_article_with_name = $1
    end
  end
end


#
# This is the request for CGI-based queries. 

class CGIRequest < WebRequest
  # This insulates the user from having to do:
  # variable, = @cgi['param_name']
  # in order to retrieve a single value from CGI[].
  class SingleValueParams
    def initialize(cgi)
      @cgi = cgi
    end
    def [](key)
      res, = @cgi[key]
      res
    end
    def has_key?(key)
      @cgi.has_key?(key)
    end
  end

  def initialize
    @environment = ENV
    @parameters = SingleValueParams.new(CGI.new)
    super
  end
end
