# The RDoc converter reads files in RDoc format. The first line is
# a title, the rest is the body

require 'RDocMarkup'
require 'HyperLink'

class RDocConvertor < BaseConvertor
  handles "rdoc"

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
    markup = RDocMarkup.new
    h = HyperLinkHtml.new(file_name, all_entries)
    body  = markup.convert(body, h)
    synopsis = markup.convert(synopsis, h) if synopsis

    HTMLEntry.new(title, body, synopsis, self)
  end

  def convert_plain(file_name, f, all_entries)
    f.read
  end

end

