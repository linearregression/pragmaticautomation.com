#!/usr/local/bin/ruby

$:.unshift "."


require 'RubLog'
require 'Request'
require 'View'

require 'convertors/RDoc'
require 'convertors/Text'
require 'convertors/Html'

blog = RubLog.new("doc", CGIRequest.new)
blog.top_title = "Welcome to RubLog"
blog.info_url  = "doc/Welcome.rdoc"



####################################################################
#   Sidebars
####################################################################

require "sidebar/Contents"    # show summary of this blog's contents
OutlineSidebar.new


require 'sidebar/Search'
SearchSidebar.new("/tmp/search_cache_file")

require 'sidebar/Calendar'
CalendarSidebar.new


require "sidebar/LinkHolder"  # Display one or more lists of links
LinkHolder.new("Useful Stuff",
        "http://www.rubygarden.org"          => "Ruby Garden",
        "http://www.pragmaticprogrammer.com" => "Pragmatic Programmer"
)

require "sidebar/BlogRoll"
BlogRoll.new("Blogorrhea",
            [ 'PragDave', 'http://pragprog.com/pragdave' ],
            [ '/\ndy', 'http://www.toolshed.com/blog' ],
     	    [ 'James Duncan Davidson', 'http://x180.net/Blog'],
            [ 'Glenn Vanderburg',
              'http://www.vanderburg.org/cgi-bin/glv/blosxom',
              'http://www.vanderburg.org/cgi-bin/glv/blosxom?flav=rss' ],
            [ 'Chad Fowler',
              'http://www.chadfowler.com',
              'http://www.chadfowler.com/?rss' ],
            [ 'Brian Marick', 'http://www.testing.com/cgi-bin/blog' ]

 )


######################################################################

View.display(blog)
