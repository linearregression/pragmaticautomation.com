#!/usr/local/bin/ruby
#
# A Webrick servlet that runs RubLog. This is unsupported code.
#
# Graciously written by Chad Fowler.

require 'webrick'
require 'optparse'
require 'RubLog'
require "sidebar/Contents"    # show summary of this blog's contents
require 'sidebar/Search'
require "sidebar/LinkHolder"  # Display one or more lists of links

#######
# Adapter maps WEBrick requests to RubLog ones
#######

class WebrickRequest < WebRequest
  def initialize(req)
    @environment = req.meta_vars
    @parameters = req.query
    super()
  end
end

#####
# and the same for response objects
#####

class WebrickResponse 
  def initialize(webrick_response)
    @response = webrick_response
  end

  def add_header(key,value)
    @response[key] = value
  end

  def write_headers
    # Webrick will take care of this on its own.
  end

  def << (string)
    @response.body << string
  end
end

######################################################################
#
# Here's the actual WEBRick servlet. On initialization it creates
# a new RubLog object. On each request it then uses that object
# to create a response.
#

class RubLogServlet < WEBrick::HTTPServlet::AbstractServlet
  def initialize(config)
    super
    RubLog::load_convertors(*%w{ RDoc Text Html })
    @blog = RubLog.new("doc")
    @blog.top_title       = "RubLog"
    @blog.rss_description = "Sample RubLog Using WEBrick"
    @blog.info_url        = "RubLog/UsingRubLog.rdoc"
    @blog.max_entries_per_page = 5
    create_sidebars
  end

  # Handle an incoming request by delegating to RubLog
  def do_GET(req, res)
    res['content-type'] = 'text/html'
    @blog.process_request(WebrickRequest.new(req), WebrickResponse.new(res))
  end

  alias do_POST do_GET

  private

  def create_sidebars
    OutlineSidebar.new
    SearchSidebar.new("/tmp/search_cache_file")
    LinkHolder.new("Useful Stuff",
                   "http://www.rubygarden.org"          => "Ruby Garden",
                   "http://www.pragmaticprogrammer.com" => "Pragmatic Programmer",
                   "http://www.artima.com"              => "Artima"
                   )
  end

end

######################################################################
#
# Create the environment for the servlet

if __FILE__ == $0

  port = 8808

  opts = OptionParser.new
  opts.on("-p", "--port PORT", Integer) {|val| port = val}
  opts.on("-h", "--help")               { puts opts.to_s; exit }
  opts.parse(*ARGV)

  logger = WEBrick::Log::new(STDERR, WEBrick::Log::DEBUG)

  server = WEBrick::HTTPServer.new(:Port         => port,
                                   :StartThreads => 1,
                                   :Logger       => logger)
  server.mount("/", RubLogServlet)
  trap("INT"){ server.shutdown }
  server.start
end
