# Rublog Textile converter version 0.45 by Rudi Cilibrasi (cilibrar@gmail.com)
# The Textile converter reads files in Textile format. The first line is
# a title, the rest is the body

# Change this if you installed redcloth using something other than rubygems
require 'rubygems'
require 'redcloth'

# You shouldn't change anything below this line
require 'RDocMarkup'
require 'HyperLink'

class TextileConvertor < BaseConvertor
  handles "txl"

  def convert_html(file_name, f, all_entries)
    title = CGI.escapeHTML((f.gets || '-- Empty Article --').sub(/^=+\s*/, ''))
    body = f.read || ''

    synopsis = nil

    if body.sub!(/^summary::(.*?\n\s*\n)/m, '\1')
      synopsis = $1
    elsif body.sub!(/^start summary::(.*?)\nend summary::/m, '\1')
      synopsis = $1
    end

    if body.sub!(/^abstract::(.*?\n\s*\n)/m, '')
      synopsis = $1
    elsif body.sub!(/^start abstract::(.*?)\nend abstract::/m, '')
      synopsis = $1
    end

    markup = RedCloth.new(body)
    body  = markup.to_html
    synopsis = RedCloth.new(synopsis).to_html if synopsis

    HTMLEntry.new(title, body, synopsis, self)
  end

  def convert_plain(file_name, f, all_entries)
    f.read
  end

end
