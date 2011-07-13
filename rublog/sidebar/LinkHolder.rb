require 'Sidebar'

# A simple sidebar that holds a collection of links. Use it with
#
# require 'sidebar/LinkHolder'
#
# links1 = LinkHolder.new("Title One",
#                         "href" => "name",
#                         "href" => "name",
#                         )
#
# If the links start with two digits and a colon, we strip the digits
# before display. This allows the links to be sorted

class LinkHolder < Sidebar

  def initialize(title, links)
    super()

    @title = title
    @body = ""

    links = links.to_a.sort {|l1,l2| l1[1] <=> l2[1] }

    links.each do |ref, text|
      text = text.sub(/^\d\d:/, '')
      if ref.strip.empty?
	@body << text << "<br />"
      else
	@body << "<a href=\"#{ref}\">#{text}</a><br />"
      end
    end
  end

  # no need for generate method here...
end
