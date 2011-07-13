#!/usr/bin/ruby
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


### CHANGE: update to point to the directory where you installed RubLog
RubLogSourceLocation("/Users/dave/Work/ruby/rublog")

#########
# CHANGE: Point to the directory containing your blog files (or the
# top of a CVS tree). The default value opr 'nil' will bring up
# a blog containing RubLog's own documentation. Once you've read this,
# you'll want to put a directory name here (as a string)
BLOG_DIR = nil


#########
### OPTION: which input convertors you want to support
### Options include RDoc, Text, Html, Markdown (Bluecloth)
### You can also use Usemode to parse entries from a Usemod wiki
RubLog::load_convertors(*%w{ RDoc Text Html })


blog = RubLog.new(BLOG_DIR)

#########
# OPTION: set these parameters if you want to override the default
# values

### Set the style you'd like the blog to use: standard,
### purple, movable (requires an external movable type stylesheet), or
### wordpress (requires a wordpress stylesheet)
# blog.style = "standard"


###  Title shown at top of page
# blog.top_title = "RubLog"

###
# How many blog entries to show on a page
# blog.max_entries_per_page = 5

### The first 'n' entries will be shown in full, the rest
### will display just their summaries or abstracts
#  blog.dont_summarize_count = 1

### If true, entries after the first 'dont_summarize_count' will
### be shown as synopses (if the entry has an abstract)
# blog.allow_synopsis = false

### If true, if a synopsis is present it will be sent to rss readers,
### otherwise the full article will be sent
# blog.always_synopsis_rss = false

### Information added to the RSS feed we produce
# blog.rss_description  = "RubLog"
# blog.rss_image_title  = nil
# blog.rss_image_link   = nil
# blog.rss_image_url    = nil
# blog.rss_encoding     = 'iso-8859-1'

## Either any absolute url (http://...) or a blog-relative page
## that gives information about this blog. You might want to add
## the page 'RubLog/UsingRublog.rdoc' as this link
# blog.info_url         = "RubLog/UsingRubLog.rdoc"

### A copyright notice
# blog.copyright        = "#{Time.now.year} Dave Thomas"

### An external stylesheet to use when displaying pages. If
### not specified, a style sheet will be embedded with every page
# blog.external_stylesheet =     "http://my.site.com/rublog.css"

### A regexp used to match directory names to ignore. If running
## RubLog from a CVS repository, you'll probably want
# blog.ignore_directory_pattern =  /Attic/

### Regexp specifying filenames to ignore when scanning for things to
### display.
# blog.ignore_filename_pattern  = /(~|.bak)$/

### The name of the style file used to create printable entries
#blog.print_style_name          = "print"

### If true, RubLog will generate cross-reference URLs that match by name,
### rather than using absolute links to the exact article. This allows you
### to change the target of a link and have the link still work
# blog.use_dynamic_urls = false


### If set, a link will to mailto: URL will be generated
### for each article
# blog.comment_email_address = nil

###
### Advanced: A proc which, given a file name and a File::Stat structure
### returns an integer representing the modification time of the file. 
### Override if you want to do something like encode the entries' dates
### in their names (allowing you to edit an entry without modifying its
### order
#blog.mtime_getter

### Filters are currently disabled
# blog.extra_filter          =   "Double"




########################################

require "sidebar/Contents"    # show summary of this blog's contents
OutlineSidebar.new

########################################

require 'sidebar/Search'
SearchSidebar.new("/tmp/search_cache_file")

########################################

require "sidebar/LinkHolder"  # Display one or more lists of links
LinkHolder.new("Useful Stuff",
        "http://www.rubygarden.org"          => "Ruby Garden",
        "http://www.pragmaticprogrammer.com" => "Pragmatic Programmer",
	"http://www.artima.com"              => "Artima"
)

########################################

require "sidebar/BlogRoll"
BlogRoll.new("Blogorrhea",
            [ '/\ndy', 'http://www.toolshed.com/blog' ],
            [ 'James Duncan Davidson', 'http://x180.net/Blog'],
            [ 'Glenn Vanderburg', 'http://www.vanderburg.org/Blog' ],
            [ 'Chad Fowler',
              'http://www.chadfowler.com',
              'http://www.chadfowler.com/?rss' ],
            [ 'Brian Marick', 'http://www.testing.com/cgi-bin/blog' ]

 )


########################################

require "sidebar/Calendar"
CalendarSidebar.new

########################################

require "sidebar/MiniBlog"
MiniBlogs.create_for("sidebar_directory")

######################################################################

blog.process_request(CGIRequest.new, CGIResponse.new)


######################################################################
###
### Support stuff - do not change
###

BEGIN {
    def RubLogSourceLocation(dir)
      $: << dir
      require 'RubLog'
    end

  }
