
# The text convertor reads a plain text file. HTML is escaped
class PlainTextConvertor < BaseConvertor
  handles "txt", "text"

  def convert_html(file_name, f, all_entries)
    title = CGI.escapeHTML(f.gets||"-- Empty Article --")
    body  = CGI.escapeHTML(f.read||"")
    body.gsub!(/^\s*$/, "<p />\n")
    HTMLEntry.new(title, body, body, self)
  end

  def convert_plain(file_name, f, all_entries)
    f.read
  end

end

