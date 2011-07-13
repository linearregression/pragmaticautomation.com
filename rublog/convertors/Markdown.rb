# The Markdown converter reads files in Markdown format. 
# It uses BlueCloth (a Ruby converter for Markdown) to do the coversion.
# This class also depends on RubyGems. It is assumed BlueCloth is installed
# as a gem.
#
# If the Markdown entry uses an ATX style heading "#### ATX Heading ###"
# the hashes '#' are removed and the line becomes the title. If Markdown
# headers are used "This is the title\n===========" then the first two
# lines of the file are removeed from the body and the first line becomes
# the title.
#
# At present, this convertor does not handle WikiWords.
#
# [BlueCloth]: http://bluecloth.rubyforge.org/
# [Markdown]:  http://daringfireball.net/projects/markdown/
# [RubyGems]:  http://rubygems.rubyforge.org/wiki/wiki.pl?UserDoc
#
# AUTHOR:  Mark Reid <mark at threewordslong dot com>
# CREATED: 17th April 2004

require 'rubygems'
require_gem 'BlueCloth'

class MarkdownConvertor < BaseConvertor
  handles "md"

  def convert_html(file_name, f, all_entries)
	title = f.gets
	# ATX style titles look like this: "### Level 3 Header" with 
	# optional closing hashes. Otherwise, use the first line as
	# the title and strip the second.
	if title =~ /^\#+/
	  title.gsub(/\#/, '') 
	else
	  f.gets
	end
    title = CGI.escapeHTML(title)
    markdown = BlueCloth.new(f.read)
    body  = markdown.to_html
    HTMLEntry.new(title, body, self)
  end

  def convert_plain(file_name, f, all_entries)
    f.read
  end

end
