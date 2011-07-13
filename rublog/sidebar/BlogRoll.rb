require 'Sidebar'

# A sidebar that holds a collection of references to blogs. Use it with
#
# require 'sidebar/LinkHolder'
#
#  BlogRoll.new("Title One",
#               %w{ name, blog_url, rss_url },
#               %w{ name, blog_url, rss_url }
#              )
#

class BlogRoll < Sidebar

  def initialize(title, *links)
    super()

    @title = title
    @body = ""

    links.each do |name, url, rss|
      rss = File.join(url, "index.rss") unless rss
      @body << "<a href=\"#{rss}\">[rss]</a>&nbsp;" << 
	"<a href=\"#{url}\">#{name.gsub(/ /, '&nbsp;')}</a><br />"
    end
  end

  # no need for generate method here...
end
