#!/usr/local/bin/ruby
# This file contains the site-specific configuration for RubLog.
#
# To install RubLog copy this file to a location which permits
# web-server execution (cgi-bin or cgi-local are good
# candidates). You'll probably need to make it executable.
#
# Edit the lines below to configure RubLog to your site. Lines
# marked 'CHANGE:' require a change for yoour site, those
# marked 'OPTION:' can be changed if you want
#
# Then point your browser at the rublog.cgi and enjoy.


# CHANGE: update to point to the directory where you installed RubLog
$: << "/home/dave/work/ruby/rublog"
#$: << "/Users/mike/tools/ruby/rublog"

require 'RubLog'
require 'Request'
require 'View'

#########
# OPTION: which input convertors you want to support
require 'convertors/RDoc'
require 'convertors/Text'
require 'convertors/Html'
# require 'convertors/Usemod'    # handle a Usemod wiki

#########
# CHANGE: alter the parameter to point to the directory containing your blog
# files (or the top of a CVS tree)
#blog = RubLog.new("/Users/mike/work/Bookshelf/titles/AUTO/blog", CGIRequest.new("movable")) {
blog = RubLog.new("/home/bookshelf/Bookshelf/titles/AUTO/blog")

blog.style = "movable"
blog.max_entries_per_page = 15
blog.ignore_directory_pattern = /Attic|data/
blog.top_title = "Pragmatic Automation"
blog.copyright = "#{Time.now.year} Pragmatic Programmers, LLC"
blog.rss_description = %{Pragmatic Automation. Hosted by Mike Clark.}
blog.info_url= "Syndication" 
blog.allow_synopsis = true
blog.always_synopsis_rss = false
blog.dont_summarize_count = 3
blog.rss_encoding = "iso-8859-1"
blog.external_stylesheet = "http://www.pragmaticautomation.com/css/movable_lines.css"
blog.comment_email_address = "mike@clarkware.com"



########################################

require "sidebar/LinkHolder"
LinkHolder.new("About",
  "http://www.pragmaticautomation.com/cgi-bin/pragauto.cgi/Welcome.rdoc" =>
    "01:Masthead",
  "http://www.pragmaticautomation.com/cgi-bin/pragauto.cgi/TuningIn.rdoc" =>
    "02:Tuning In",
  "http://www.pragmaticautomation.com/index.rss" =>
    '03:<img src="/images/xml.gif" alt="RSS Feed" />'
)

require "sidebar/Contents"    # show summary of this blog's contents
OutlineSidebar.new

require "sidebar/MiniBlog"
MiniBlogs.create_for("/home/dave/work/Bookshelf/titles/AUTO/blog_control/miniblogs")
#MiniBlogs.create_for("/Users/mike/work/Bookshelf/titles/AUTO/blog_control/miniblogs")


require "sidebar/LinkHolder"
LinkHolder.new("Buy The Book!",
  "http://www.pragmaticprogrammer.com/sk/auto" =>
    '01:<center><img src="http://pragmaticprogrammer.com/images/sk_auto_small.gif"></center>',
  "" => "01:Buy now:",
  "http://pragmaticprogrammer.com/shopsite_sc/shopping_cart/order.cgi?storeid=*14195f685aff11071b3e3632&dbname=products&itemnum=12&function=add" => "02:&nbsp;&nbsp;Paper book",
  "http://pragmaticprogrammer.com/shopsite_sc/shopping_cart/order.cgi?storeid=*14195f685aff11071b3e3632&dbname=products&itemnum=11&function=add" => "03:&nbsp;&nbsp;PDF",
  "http://pragmaticprogrammer.com/shopsite_sc/shopping_cart/order.cgi?storeid=*14195f685aff11071b3e3632&dbname=products&itemnum=10&function=add" => "04:&nbsp;&nbsp;Combo pack"
)

require "sidebar/LinkHolder"
LinkHolder.new("Sample Chapters",
  "http://www.pragmaticprogrammer.com/starter_kit/au/contents.pdf" => "01:Table Of Contents",
  "http://www.pragmaticprogrammer.com/starter_kit/au/introduction.pdf" => "02:Introduction",
  "http://www.pragmaticprogrammer.com/starter_kit/au/scheduled.pdf" => "03:Scheduled Builds",
  "http://pragmaticprogrammer.com/starter_kit/au/PragmaticAutomationSummary.pdf" => 
     "99:Summary Card"
)

LinkHolder.new("Downloads",
  "http://pragmaticprogrammer.com/starter_kit/au/au00.zip" => "Book's Example Code"
)

LinkHolder.new("Resources",
  "http://clarkware.com" => "Clarkware Consulting",
  "http://www.pragmaticprogrammer.com" => "Pragmatic Programmer"
)

require 'sidebar/Search'
SearchSidebar.new("/tmp/pragauto", nil)

require "sidebar/Calendar"
CalendarSidebar.new

MiniBlogs.create_for("/var/www/pragmaticautomation/data")

blog.process_request(CGIRequest.new, CGIResponse.new)
