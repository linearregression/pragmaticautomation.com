# The html convertor simply reads a file. We look for a natural
# title. If we can't find it, we use the first line (removing it
# if it doesn't look like valid HTML)
require 'BaseConvertor'

class HtmlConvertor < BaseConvertor
  handles "html", "htm"

  def convert_html(file_name, f, all_entries)
    body  = f.read || ""
    	title = "Untitled"
    if body =~ /<title>(..*?)<\/title>/m
		title = $1
    elsif body =~ /<h1[^><]*>(.*?)<\/h1>/
		title = $1
    elsif body.sub!(/\A\s*([^\s<].*)/, '')
		title = $1
    end

    synopsis = body

    if body.sub!(/<summary>(..*?)<\/summary>/m, '<span class="synopsis">\1</span>')
      synopsis = $1
    end

    if body.sub!(/<abstract>(..*?)<\/abstract>/m, '')
      synopsis = $1
    end


    title = CGI.escapeHTML(title)

    HTMLEntry.new(title, body, synopsis, self)
  end

  # Simple-minded attempt to strip HTML from a source file
  def convert_plain(file_name, f, all_entries)
    txt = f.read
    txt.gsub(/<[^>]+?>/, '')
  end

end
